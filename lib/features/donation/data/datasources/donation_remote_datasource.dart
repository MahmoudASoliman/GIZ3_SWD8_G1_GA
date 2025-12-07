import 'dart:math';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/donation_model.dart';

abstract class DonationRemoteDataSource {
  Future<Map<String, dynamic>> createDonationOffer({
    required String requestId,
    required String donorName,
    required String donorPhone,
    String? donorEmail,
  });

  Future<List<DonationModel>> getDonationsForRequest(String requestId);

  Future<List<DonationModel>> getMyDonations();

  Future<DonationModel> updateDonationStatus(String donationId, String status);

  Future<Map<String, dynamic>> verifyOtp(String donationId, String otpCode);

  Future<DonationModel> getDonationById(String donationId);
}

@Injectable(as: DonationRemoteDataSource)
class DonationRemoteDataSourceImpl implements DonationRemoteDataSource {
  final SupabaseClient _supabaseClient;

  DonationRemoteDataSourceImpl(this._supabaseClient);

  /// Generate a 6-digit OTP code
  String _generateOtp() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  @override
  Future<Map<String, dynamic>> createDonationOffer({
    required String requestId,
    required String donorName,
    required String donorPhone,
    String? donorEmail,
  }) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      final otpCode = _generateOtp();

      // Get user type
      final userResponse = await _supabaseClient
          .from('users')
          .select('user_type')
          .eq('id', userId!)
          .single();

      final donorType = userResponse['user_type'] ?? 'donor';

      // Insert into donations table
      final response = await _supabaseClient
          .from('donations')
          .insert({
            'request_id': requestId,
            'donor_user_id': userId,
            'donor_type': donorType,
            'donor_name': donorName,
            'donor_phone': donorPhone,
            'donor_email': donorEmail,
            'otp_code': otpCode,
            'otp_expires_at': DateTime.now()
                .add(const Duration(hours: 24))
                .toIso8601String(),
            'status': 'pending',
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      // Send notification to hospital about new donation offer
      try {
        // Get request details to find hospital
        final requestData = await _supabaseClient
            .from('blood_requests')
            .select('*, hospitals!inner(id, user_id, name)')
            .eq('id', requestId)
            .single();

        final hospitalUserId = requestData['hospitals']?['user_id'];
        final patientName = requestData['patient_name'] ?? 'Patient';
        final bloodGroup = requestData['blood_group'] ?? '';

        if (hospitalUserId != null) {
          // Save notification to database
          await _supabaseClient.from('notifications').insert({
            'user_id': hospitalUserId,
            'title': '🩸 New Donation Offer!',
            'body':
                '$donorName wants to donate $bloodGroup blood for $patientName',
            'type': 'request_accepted',
            'data': {
              'request_id': requestId,
              'donation_id': response['id'],
              'donor_name': donorName,
              'donor_phone': donorPhone,
              'blood_group': bloodGroup,
            },
            'is_read': false,
          });

          // Try to send push notification
          try {
            final hospitalUser = await _supabaseClient
                .from('users')
                .select('fcm_token')
                .eq('id', hospitalUserId)
                .maybeSingle();

            final fcmToken = hospitalUser?['fcm_token'];

            if (fcmToken != null) {
              await _supabaseClient.functions.invoke(
                'send-notification',
                body: {
                  'type': 'single',
                  'fcm_token': fcmToken,
                  'title': '🩸 New Donation Offer!',
                  'body':
                      '$donorName wants to donate $bloodGroup blood for $patientName',
                  'data': {
                    'type': 'request_accepted',
                    'request_id': requestId,
                    'donor_name': donorName,
                  },
                },
              );
            }
          } catch (fcmError) {
            // FCM error silently handled (non-fatal)
          }
        }
      } catch (notifError) {
        // Notification error silently handled
      }

      return response;
    } catch (e) {
      throw Exception('Failed to create donation offer: $e');
    }
  }

  @override
  Future<List<DonationModel>> getDonationsForRequest(String requestId) async {
    try {
      final response = await _supabaseClient
          .from('donations')
          .select()
          .eq('request_id', requestId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => DonationModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get donations: $e');
    }
  }

  @override
  Future<List<DonationModel>> getMyDonations() async {
    final userId = _supabaseClient.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _supabaseClient
        .from('donations')
        .select()
        .eq('donor_user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => DonationModel.fromJson(json))
        .toList();
  }

  @override
  Future<DonationModel> updateDonationStatus(
    String donationId,
    String status,
  ) async {
    final response = await _supabaseClient
        .from('donations')
        .update({'status': status})
        .eq('id', donationId)
        .select()
        .single();

    return DonationModel.fromJson(response);
  }

  @override
  Future<Map<String, dynamic>> verifyOtp(
    String donationId,
    String otpCode,
  ) async {
    try {
      // Get the donation first
      final donation = await _supabaseClient
          .from('donations')
          .select()
          .eq('id', donationId)
          .single();

      // Check if OTP matches
      if (donation['otp_code'] == otpCode) {
        // Update donation status to completed
        await _supabaseClient
            .from('donations')
            .update({
              'status': 'completed',
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', donationId);

        // Also update the blood request status
        final requestId = donation['request_id'] as String;

        try {
          await _supabaseClient
              .from('blood_requests')
              .update({
                'status': 'completed',
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('id', requestId);
        } catch (requestError) {
          // If we can't update blood_requests (RLS issue), still return success
          // The donation is completed which is the main thing
        }

        // Send notification to hospital
        try {
          // Get request details to find hospital
          final requestData = await _supabaseClient
              .from('blood_requests')
              .select('*, hospitals!inner(id, user_id, name)')
              .eq('id', requestId)
              .single();

          final hospitalUserId = requestData['hospitals']?['user_id'];
          final patientName = requestData['patient_name'] ?? 'Patient';
          final bloodGroup = requestData['blood_group'] ?? '';
          final donorName = donation['donor_name'] ?? 'A donor';

          if (hospitalUserId != null) {
            // Save notification to database FIRST (doesn't need FCM token)
            await _supabaseClient.from('notifications').insert({
              'user_id': hospitalUserId,
              'title': '✅ Donation Completed!',
              'body':
                  '$donorName has completed the $bloodGroup blood donation for $patientName',
              'type': 'request_completed',
              'data': {
                'request_id': requestId,
                'donation_id': donationId,
                'donor_name': donorName,
                'blood_group': bloodGroup,
              },
              'is_read': false,
            });

            // Get hospital's FCM token for push notification
            final hospitalUser = await _supabaseClient
                .from('users')
                .select('fcm_token')
                .eq('id', hospitalUserId)
                .maybeSingle();

            final fcmToken = hospitalUser?['fcm_token'];

            // Send push notification if FCM token exists
            if (fcmToken != null) {
              try {
                await _supabaseClient.functions.invoke(
                  'send-notification',
                  body: {
                    'type': 'single',
                    'fcm_token': fcmToken,
                    'title': '✅ Donation Completed!',
                    'body':
                        '$donorName has completed the $bloodGroup blood donation for $patientName',
                    'data': {
                      'type': 'request_completed',
                      'request_id': requestId,
                      'donation_id': donationId,
                      'donor_name': donorName,
                      'blood_group': bloodGroup,
                    },
                  },
                );
              } catch (fcmError) {
                // FCM error silently handled (non-fatal)
              }
            }
          }
        } catch (notifError) {
          // Don't fail the verification if notification fails
        }

        return {'success': true, 'message': 'Donation completed successfully'};
      } else {
        throw Exception('Invalid OTP code');
      }
    } catch (e) {
      throw Exception('Failed to verify OTP: $e');
    }
  }

  @override
  Future<DonationModel> getDonationById(String donationId) async {
    final response = await _supabaseClient
        .from('donations')
        .select()
        .eq('id', donationId)
        .single();

    return DonationModel.fromJson(response);
  }
}
