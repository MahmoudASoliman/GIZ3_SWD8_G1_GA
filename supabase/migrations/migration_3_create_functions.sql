-- Migration: Create database functions and triggers
-- Created: 2025-01-01
-- Description: Creates functions for notifications and automatic triggers

-- ============================================
-- 1. Function to create user profile after signup
-- ============================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  -- Insert into users table
  INSERT INTO public.users (id, email, user_type)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'user_type', 'donor')
  );
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger for new user signup
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- 2. Function to notify donors about new requests
-- ============================================
CREATE OR REPLACE FUNCTION public.notify_matching_donors()
RETURNS TRIGGER AS $$
DECLARE
  donor_record RECORD;
  notification_id UUID;
BEGIN
  -- Loop through matching donors
  FOR donor_record IN
    SELECT 
      d.id as donor_id,
      d.user_id,
      d.full_name,
      u.fcm_token
    FROM public.donors d
    JOIN public.users u ON d.user_id = u.id
    WHERE 
      d.blood_group = NEW.blood_group
      AND d.governate = NEW.governate
      AND d.is_available = true
      AND u.fcm_token IS NOT NULL
  LOOP
    -- Create in-app notification
    INSERT INTO public.notifications (
      user_id,
      title,
      body,
      type,
      data
    ) VALUES (
      donor_record.user_id,
      'طلب تبرع جديد! 🩸',
      format('مطلوب متبرع بفصيلة %s في %s - %s', NEW.blood_group, NEW.city, NEW.patient_name),
      'new_request',
      jsonb_build_object(
        'request_id', NEW.id,
        'blood_group', NEW.blood_group,
        'city', NEW.city,
        'urgency_level', NEW.urgency_level
      )
    )
    RETURNING id INTO notification_id;

    -- Call Edge Function to send FCM notification
    -- This will be handled by Edge Function
    PERFORM
      net.http_post(
        url := current_setting('app.settings.edge_function_url', true) || '/send-notification',
        headers := jsonb_build_object(
          'Content-Type', 'application/json',
          'Authorization', 'Bearer ' || current_setting('app.settings.service_role_key', true)
        ),
        body := jsonb_build_object(
          'fcm_token', donor_record.fcm_token,
          'notification', jsonb_build_object(
            'title', 'طلب تبرع جديد! 🩸',
            'body', format('مطلوب متبرع بفصيلة %s في %s', NEW.blood_group, NEW.city)
          ),
          'data', jsonb_build_object(
            'type', 'new_request',
            'request_id', NEW.id::text,
            'click_action', 'FLUTTER_NOTIFICATION_CLICK'
          )
        )
      );
  END LOOP;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger for new blood request
DROP TRIGGER IF EXISTS on_blood_request_created ON public.blood_requests;
CREATE TRIGGER on_blood_request_created
  AFTER INSERT ON public.blood_requests
  FOR EACH ROW
  EXECUTE FUNCTION public.notify_matching_donors();

-- ============================================
-- 3. Function to notify hospital when donor accepts
-- ============================================
CREATE OR REPLACE FUNCTION public.notify_hospital_on_acceptance()
RETURNS TRIGGER AS $$
DECLARE
  hospital_user_id UUID;
  hospital_fcm_token TEXT;
  donor_name TEXT;
BEGIN
  -- Check if request was just accepted
  IF OLD.status = 'pending' AND NEW.status = 'accepted' AND NEW.accepted_by IS NOT NULL THEN
    
    -- Get hospital info
    SELECT h.user_id, u.fcm_token, d.full_name
    INTO hospital_user_id, hospital_fcm_token, donor_name
    FROM public.hospitals h
    JOIN public.users u ON h.user_id = u.id
    JOIN public.donors d ON d.id = NEW.accepted_by
    WHERE h.id = NEW.hospital_id;

    -- Create in-app notification
    INSERT INTO public.notifications (
      user_id,
      title,
      body,
      type,
      data
    ) VALUES (
      hospital_user_id,
      'تم قبول الطلب! ✅',
      format('المتبرع %s قبل طلب التبرع لـ %s', donor_name, NEW.patient_name),
      'request_accepted',
      jsonb_build_object(
        'request_id', NEW.id,
        'donor_name', donor_name,
        'blood_group', NEW.blood_group
      )
    );

    -- Send FCM notification if token exists
    IF hospital_fcm_token IS NOT NULL THEN
      PERFORM
        net.http_post(
          url := current_setting('app.settings.edge_function_url', true) || '/send-notification',
          headers := jsonb_build_object(
            'Content-Type', 'application/json',
            'Authorization', 'Bearer ' || current_setting('app.settings.service_role_key', true)
          ),
          body := jsonb_build_object(
            'fcm_token', hospital_fcm_token,
            'notification', jsonb_build_object(
              'title', 'تم قبول الطلب! ✅',
              'body', format('المتبرع %s قبل طلب التبرع', donor_name)
            ),
            'data', jsonb_build_object(
              'type', 'request_accepted',
              'request_id', NEW.id::text,
              'click_action', 'FLUTTER_NOTIFICATION_CLICK'
            )
          )
        );
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger for request acceptance
DROP TRIGGER IF EXISTS on_blood_request_accepted ON public.blood_requests;
CREATE TRIGGER on_blood_request_accepted
  AFTER UPDATE ON public.blood_requests
  FOR EACH ROW
  EXECUTE FUNCTION public.notify_hospital_on_acceptance();

-- ============================================
-- 4. Function to get available donors for request
-- ============================================
CREATE OR REPLACE FUNCTION public.get_matching_donors(
  p_blood_group TEXT,
  p_governate TEXT,
  p_limit INTEGER DEFAULT 50
)
RETURNS TABLE (
  donor_id UUID,
  full_name TEXT,
  phone_number TEXT,
  blood_group TEXT,
  city TEXT,
  age INTEGER,
  last_donation_date DATE,
  is_available BOOLEAN
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    d.id,
    d.full_name,
    d.phone_number,
    d.blood_group,
    d.city,
    d.age,
    d.last_donation_date,
    d.is_available
  FROM public.donors d
  WHERE 
    d.blood_group = p_blood_group
    AND d.governate = p_governate
    AND d.is_available = true
  ORDER BY 
    CASE 
      WHEN d.last_donation_date IS NULL THEN 0
      ELSE EXTRACT(EPOCH FROM (NOW() - d.last_donation_date))
    END DESC
  LIMIT p_limit;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 5. Function to get user statistics
-- ============================================
CREATE OR REPLACE FUNCTION public.get_donor_stats(p_donor_id UUID)
RETURNS TABLE (
  total_donations INTEGER,
  pending_requests INTEGER,
  completed_requests INTEGER,
  last_donation_date DATE
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    COUNT(*)::INTEGER as total_donations,
    COUNT(*) FILTER (WHERE status = 'accepted')::INTEGER as pending_requests,
    COUNT(*) FILTER (WHERE status = 'completed')::INTEGER as completed_requests,
    MAX(updated_at)::DATE as last_donation_date
  FROM public.blood_requests
  WHERE accepted_by = p_donor_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.get_hospital_stats(p_hospital_id UUID)
RETURNS TABLE (
  total_requests INTEGER,
  pending_requests INTEGER,
  accepted_requests INTEGER,
  completed_requests INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    COUNT(*)::INTEGER as total_requests,
    COUNT(*) FILTER (WHERE status = 'pending')::INTEGER as pending_requests,
    COUNT(*) FILTER (WHERE status = 'accepted')::INTEGER as accepted_requests,
    COUNT(*) FILTER (WHERE status = 'completed')::INTEGER as completed_requests
  FROM public.blood_requests
  WHERE hospital_id = p_hospital_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
