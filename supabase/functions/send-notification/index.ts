// Supabase Edge Function: Send FCM Notification (V1 API)
// Supports: Single token, Topic, and Blood Request notifications
// Uses OAuth 2.0 with Service Account for authentication
// Note: These imports work in Deno runtime (Supabase Edge Functions)

// @ts-ignore - Deno module
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
// @ts-ignore - Deno module
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
// @ts-ignore - Deno module
import { create } from "https://deno.land/x/djwt@v2.8/mod.ts";

declare const Deno: {
    env: {
        get(key: string): string | undefined;
    };
};

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

// ============================================
// TYPES
// ============================================

// Type 1: Send to single FCM token
interface SingleTokenRequest {
    type?: 'single';
    fcm_token: string;
    title: string;
    body: string;
    data?: Record<string, string>;
}

// Type 2: Send to FCM topic
interface TopicRequest {
    type: 'topic';
    topic: string;
    title: string;
    body: string;
    data?: Record<string, string>;
}

// Type 3: Blood request notification (sends to matching donors)
interface BloodRequestNotification {
    type: 'blood_request';
    blood_group: string;
    hospital_name: string;
    governate: string;
    city: string;
    patient_name?: string;
    urgency_level?: string;
    request_id: string;
}

type NotificationRequest = SingleTokenRequest | TopicRequest | BloodRequestNotification;

// ============================================
// HELPER FUNCTIONS
// ============================================

async function getAccessToken(serviceAccount: any): Promise<string> {
    const now = Math.floor(Date.now() / 1000);

    const payload = {
        iss: serviceAccount.client_email,
        sub: serviceAccount.client_email,
        aud: "https://oauth2.googleapis.com/token",
        iat: now,
        exp: now + 3600,
        scope: "https://www.googleapis.com/auth/firebase.messaging",
    };

    // Parse PEM private key
    const pemContents = serviceAccount.private_key
        .replace('-----BEGIN PRIVATE KEY-----', '')
        .replace('-----END PRIVATE KEY-----', '')
        .replace(/\n/g, '');

    const binaryKey = Uint8Array.from(atob(pemContents), c => c.charCodeAt(0));

    const privateKey = await crypto.subtle.importKey(
        "pkcs8",
        binaryKey,
        { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
        false,
        ["sign"]
    );

    const jwt = await create({ alg: "RS256", typ: "JWT" }, payload, privateKey);

    const response = await fetch("https://oauth2.googleapis.com/token", {
        method: "POST",
        headers: { "Content-Type": "application/x-www-form-urlencoded" },
        body: new URLSearchParams({
            grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
            assertion: jwt,
        }),
    });

    const data = await response.json();
    if (!data.access_token) {
        throw new Error('Failed to get access token: ' + JSON.stringify(data));
    }
    return data.access_token;
}

// Send to single FCM token
async function sendToToken(
    accessToken: string,
    projectId: string,
    token: string,
    title: string,
    body: string,
    data?: Record<string, string>
) {
    const fcmPayload = {
        message: {
            token: token,
            notification: { title, body },
            data: data || {},
            android: {
                priority: 'high',
                notification: {
                    sound: 'default',
                    color: '#D32F2F',
                    channelId: 'blood_donation_channel',
                    clickAction: 'FLUTTER_NOTIFICATION_CLICK',
                },
            },
            apns: {
                payload: {
                    aps: {
                        sound: 'default',
                        badge: 1,
                        contentAvailable: true,
                    },
                },
            },
        },
    };

    const fcmUrl = `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`;
    return await fetch(fcmUrl, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${accessToken}`,
        },
        body: JSON.stringify(fcmPayload),
    });
}

// Send to FCM topic
async function sendToTopic(
    accessToken: string,
    projectId: string,
    topic: string,
    title: string,
    body: string,
    data?: Record<string, string>
) {
    const fcmPayload = {
        message: {
            topic: topic,
            notification: { title, body },
            data: data || {},
            android: {
                priority: 'high',
                notification: {
                    sound: 'default',
                    color: '#D32F2F',
                    channelId: 'blood_donation_channel',
                    clickAction: 'FLUTTER_NOTIFICATION_CLICK',
                },
            },
            apns: {
                payload: {
                    aps: {
                        sound: 'default',
                        badge: 1,
                        contentAvailable: true,
                    },
                },
            },
        },
    };

    const fcmUrl = `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`;
    return await fetch(fcmUrl, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${accessToken}`,
        },
        body: JSON.stringify(fcmPayload),
    });
}

// ============================================
// MAIN HANDLER
// ============================================

serve(async (req: Request) => {
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders });
    }

    try {
        // Get environment variables
        const SERVICE_ACCOUNT_JSON = Deno.env.get('SERVICE_ACCOUNT_JSON');
        const PROJECT_ID = Deno.env.get('PROJECT_ID');
        const SB_URL = Deno.env.get('SB_URL') || Deno.env.get('SUPABASE_URL');
        const SB_SERVICE_ROLE_KEY = Deno.env.get('SB_SERVICE_ROLE_KEY') || Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');

        if (!SERVICE_ACCOUNT_JSON || !PROJECT_ID) {
            throw new Error('Firebase configuration not complete. Set SERVICE_ACCOUNT_JSON and PROJECT_ID.');
        }

        const serviceAccount = JSON.parse(SERVICE_ACCOUNT_JSON);
        const accessToken = await getAccessToken(serviceAccount);

        const requestData: NotificationRequest = await req.json();
        const notificationType = requestData.type || 'single'; // Default to single for backward compatibility

        // ========================================
        // TYPE 1: Single Token Notification
        // ========================================
        if (notificationType === 'single' || (!requestData.type && (requestData as any).fcm_token)) {
            const data = requestData as SingleTokenRequest;

            if (!data.fcm_token || !data.title || !data.body) {
                return new Response(
                    JSON.stringify({ error: 'fcm_token, title, and body are required' }),
                    { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
                );
            }

            const response = await sendToToken(accessToken, PROJECT_ID, data.fcm_token, data.title, data.body, data.data);
            const result = await response.json();

            return new Response(
                JSON.stringify({ success: response.ok, result }),
                { status: response.ok ? 200 : 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
            );
        }

        // ========================================
        // TYPE 2: Topic Notification
        // ========================================
        if (notificationType === 'topic') {
            const data = requestData as TopicRequest;

            if (!data.topic || !data.title || !data.body) {
                return new Response(
                    JSON.stringify({ error: 'topic, title, and body are required' }),
                    { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
                );
            }

            const response = await sendToTopic(accessToken, PROJECT_ID, data.topic, data.title, data.body, data.data);
            const result = await response.json();

            return new Response(
                JSON.stringify({ success: response.ok, topic: data.topic, result }),
                { status: response.ok ? 200 : 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
            );
        }

        // ========================================
        // TYPE 3: Blood Request Notification
        // ========================================
        if (notificationType === 'blood_request') {
            const data = requestData as BloodRequestNotification;

            if (!data.blood_group || !data.hospital_name || !data.request_id) {
                return new Response(
                    JSON.stringify({ error: 'blood_group, hospital_name, and request_id are required' }),
                    { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
                );
            }

            // Prepare notification content
            const title = `🩸 Urgent: ${data.blood_group} Blood Needed`;
            const body = `${data.hospital_name} needs ${data.blood_group} blood in ${data.city}, ${data.governate}. Urgency: ${data.urgency_level || 'high'}`;
            const notificationData = {
                request_id: data.request_id,
                blood_group: data.blood_group,
                hospital_name: data.hospital_name,
                governate: data.governate,
                city: data.city,
                patient_name: data.patient_name || '',
                urgency_level: data.urgency_level || 'high',
                type: 'blood_request',
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
            };

            // Normalize blood group for topic name (e.g., "A+" -> "blood_A_positive")
            const normalizedGroup = data.blood_group
                .replace('+', '_positive')
                .replace('-', '_negative');
            const topic = `blood_${normalizedGroup}`;

            // Send to topic
            const topicResponse = await sendToTopic(accessToken, PROJECT_ID, topic, title, body, notificationData);
            const topicResult = await topicResponse.json();

            // Also send to individual donors from database (if Supabase is configured)
            let individualResults: any[] = [];

            if (SB_URL && SB_SERVICE_ROLE_KEY) {
                try {
                    const supabase = createClient(SB_URL, SB_SERVICE_ROLE_KEY);

                    // Get ALL donors with matching blood group who have FCM tokens
                    // Note: We send to ALL matching donors regardless of location
                    // The donor can decide if they want to respond based on distance
                    const { data: matchingDonors, error } = await supabase
                        .from('donors')
                        .select(`
                            id,
                            full_name,
                            user_id,
                            governate,
                            users!inner (
                                fcm_token
                            )
                        `)
                        .eq('blood_group', data.blood_group)
                        .eq('is_available', true)
                        .not('users.fcm_token', 'is', null);

                    if (!error && matchingDonors) {
                        for (const donor of matchingDonors) {
                            const fcmToken = (donor.users as any)?.fcm_token;
                            if (fcmToken) {
                                try {
                                    const response = await sendToToken(accessToken, PROJECT_ID, fcmToken, title, body, notificationData);
                                    const result = await response.json();
                                    individualResults.push({ donor_id: donor.id, success: response.ok });

                                    // Save notification to database
                                    await supabase.from('notifications').insert({
                                        user_id: donor.user_id,
                                        title: title,
                                        body: body,
                                        type: 'new_request',
                                        data: notificationData,
                                        is_read: false,
                                    });
                                } catch (e) {
                                    individualResults.push({ donor_id: donor.id, success: false, error: String(e) });
                                }
                            }
                        }
                    }
                } catch (dbError) {
                    console.error('Database error:', dbError);
                }
            }

            return new Response(
                JSON.stringify({
                    success: true,
                    message: 'Blood request notifications sent',
                    topic: { name: topic, success: topicResponse.ok, result: topicResult },
                    individual: { count: individualResults.length, results: individualResults },
                }),
                { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
            );
        }

        // Unknown type
        return new Response(
            JSON.stringify({ error: 'Invalid notification type. Use: single, topic, or blood_request' }),
            { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        );

    } catch (error) {
        console.error('Error:', error);
        return new Response(
            JSON.stringify({ success: false, error: error instanceof Error ? error.message : 'Internal server error' }),
            { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        );
    }
});
