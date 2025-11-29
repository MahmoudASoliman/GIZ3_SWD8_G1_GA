-- Migration: Donations System with OTP
-- Created: 2025-01-01
-- Description: Creates donations table for OTP-based donation verification

-- ============================================
-- 1. Create donations table
-- ============================================
CREATE TABLE IF NOT EXISTS public.donations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  request_id UUID NOT NULL REFERENCES public.blood_requests(id) ON DELETE CASCADE,
  donor_user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  donor_type TEXT NOT NULL CHECK (donor_type IN ('donor', 'hospital')),
  otp_code TEXT NOT NULL,
  otp_expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected', 'completed', 'expired')),
  -- Donor contact info (cached for hospital to see)
  donor_name TEXT NOT NULL,
  donor_phone TEXT NOT NULL,
  donor_email TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add comments
COMMENT ON TABLE public.donations IS 'Donation offers with OTP verification';
COMMENT ON COLUMN public.donations.donor_type IS 'Type of donor: donor or hospital';
COMMENT ON COLUMN public.donations.otp_code IS '6-digit OTP code for verification';
COMMENT ON COLUMN public.donations.otp_expires_at IS 'OTP expiration time (24 hours from creation)';
COMMENT ON COLUMN public.donations.status IS 'Donation status: pending, accepted, rejected, completed, expired';

-- ============================================
-- 2. Create indexes for donations
-- ============================================
CREATE INDEX IF NOT EXISTS idx_donations_request_id ON public.donations(request_id);
CREATE INDEX IF NOT EXISTS idx_donations_donor_user_id ON public.donations(donor_user_id);
CREATE INDEX IF NOT EXISTS idx_donations_status ON public.donations(status);
CREATE INDEX IF NOT EXISTS idx_donations_otp_expires_at ON public.donations(otp_expires_at);
CREATE INDEX IF NOT EXISTS idx_donations_created_at ON public.donations(created_at DESC);

-- ============================================
-- 3. Add trigger for updated_at
-- ============================================
CREATE TRIGGER update_donations_updated_at
  BEFORE UPDATE ON public.donations
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================
-- 4. Update notifications table - add new types
-- ============================================
ALTER TABLE public.notifications 
DROP CONSTRAINT IF EXISTS notifications_type_check;

ALTER TABLE public.notifications 
ADD CONSTRAINT notifications_type_check 
CHECK (type IN (
  'new_request',           -- New blood request created
  'request_accepted',      -- Request was accepted
  'request_completed',     -- Request was completed
  'donation_offer',        -- Someone wants to donate (with OTP)
  'donation_accepted',     -- Hospital accepted your donation offer
  'donation_rejected',     -- Hospital rejected your donation offer
  'donation_completed',    -- Donation successfully completed
  'otp_expired',           -- OTP has expired
  'system'                 -- System notification
));

-- ============================================
-- 5. Update blood_requests table - add companion_mobile
-- ============================================
ALTER TABLE public.blood_requests
ADD COLUMN IF NOT EXISTS companion_mobile TEXT;

COMMENT ON COLUMN public.blood_requests.companion_mobile IS 'Mobile number of patient companion';

-- ============================================
-- 6. Enable RLS on donations table
-- ============================================
ALTER TABLE public.donations ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view donations for their own requests (as hospital owner)
CREATE POLICY "Hospital can view donations for their requests"
ON public.donations
FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.blood_requests br
    JOIN public.hospitals h ON br.hospital_id = h.id
    WHERE br.id = donations.request_id
    AND h.user_id = auth.uid()
  )
);

-- Policy: Users can view their own donation offers
CREATE POLICY "Users can view their own donations"
ON public.donations
FOR SELECT
USING (donor_user_id = auth.uid());

-- Policy: Users can create donation offers
CREATE POLICY "Users can create donations"
ON public.donations
FOR INSERT
WITH CHECK (donor_user_id = auth.uid());

-- Policy: Hospital owner can update donation status (accept/reject)
CREATE POLICY "Hospital can update donation status"
ON public.donations
FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM public.blood_requests br
    JOIN public.hospitals h ON br.hospital_id = h.id
    WHERE br.id = donations.request_id
    AND h.user_id = auth.uid()
  )
);

-- Policy: Donor can update their own donation (for OTP verification)
CREATE POLICY "Donor can update own donation"
ON public.donations
FOR UPDATE
USING (donor_user_id = auth.uid());

-- ============================================
-- 7. Function to generate OTP
-- ============================================
CREATE OR REPLACE FUNCTION public.generate_otp()
RETURNS TEXT AS $$
DECLARE
  otp TEXT;
BEGIN
  -- Generate 6-digit random OTP
  otp := LPAD(FLOOR(RANDOM() * 1000000)::TEXT, 6, '0');
  RETURN otp;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 8. Function to verify OTP
-- ============================================
CREATE OR REPLACE FUNCTION public.verify_donation_otp(
  p_donation_id UUID,
  p_otp_code TEXT
)
RETURNS TABLE (
  success BOOLEAN,
  message TEXT,
  donation_id UUID
) AS $$
DECLARE
  v_donation RECORD;
BEGIN
  -- Get the donation
  SELECT * INTO v_donation
  FROM public.donations
  WHERE id = p_donation_id;
  
  -- Check if donation exists
  IF v_donation IS NULL THEN
    RETURN QUERY SELECT FALSE, 'Donation not found'::TEXT, NULL::UUID;
    RETURN;
  END IF;
  
  -- Check if already completed
  IF v_donation.status = 'completed' THEN
    RETURN QUERY SELECT FALSE, 'Donation already completed'::TEXT, p_donation_id;
    RETURN;
  END IF;
  
  -- Check if expired
  IF v_donation.otp_expires_at < NOW() THEN
    -- Update status to expired
    UPDATE public.donations SET status = 'expired' WHERE id = p_donation_id;
    RETURN QUERY SELECT FALSE, 'OTP has expired'::TEXT, p_donation_id;
    RETURN;
  END IF;
  
  -- Check if rejected
  IF v_donation.status = 'rejected' THEN
    RETURN QUERY SELECT FALSE, 'Donation was rejected'::TEXT, p_donation_id;
    RETURN;
  END IF;
  
  -- Check if OTP matches
  IF v_donation.otp_code = p_otp_code THEN
    -- Update donation status to completed
    UPDATE public.donations SET status = 'completed' WHERE id = p_donation_id;
    
    -- Update blood request status to completed
    UPDATE public.blood_requests SET status = 'completed' WHERE id = v_donation.request_id;
    
    RETURN QUERY SELECT TRUE, 'Donation completed successfully'::TEXT, p_donation_id;
  ELSE
    RETURN QUERY SELECT FALSE, 'Invalid OTP code'::TEXT, p_donation_id;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 9. Function to create donation offer
-- ============================================
CREATE OR REPLACE FUNCTION public.create_donation_offer(
  p_request_id UUID,
  p_donor_name TEXT,
  p_donor_phone TEXT,
  p_donor_email TEXT DEFAULT NULL
)
RETURNS TABLE (
  success BOOLEAN,
  message TEXT,
  donation_id UUID,
  otp_code TEXT
) AS $$
DECLARE
  v_user_id UUID;
  v_user_type TEXT;
  v_otp TEXT;
  v_donation_id UUID;
  v_request RECORD;
BEGIN
  -- Get current user
  v_user_id := auth.uid();
  
  IF v_user_id IS NULL THEN
    RETURN QUERY SELECT FALSE, 'User not authenticated'::TEXT, NULL::UUID, NULL::TEXT;
    RETURN;
  END IF;
  
  -- Get user type
  SELECT user_type INTO v_user_type FROM public.users WHERE id = v_user_id;
  
  -- Check if request exists and is pending
  SELECT * INTO v_request FROM public.blood_requests WHERE id = p_request_id;
  
  IF v_request IS NULL THEN
    RETURN QUERY SELECT FALSE, 'Request not found'::TEXT, NULL::UUID, NULL::TEXT;
    RETURN;
  END IF;
  
  IF v_request.status != 'pending' THEN
    RETURN QUERY SELECT FALSE, 'Request is no longer available'::TEXT, NULL::UUID, NULL::TEXT;
    RETURN;
  END IF;
  
  -- Check if user already has a pending donation for this request
  IF EXISTS (
    SELECT 1 FROM public.donations 
    WHERE request_id = p_request_id 
    AND donor_user_id = v_user_id 
    AND status IN ('pending', 'accepted')
  ) THEN
    RETURN QUERY SELECT FALSE, 'You already have a pending donation for this request'::TEXT, NULL::UUID, NULL::TEXT;
    RETURN;
  END IF;
  
  -- Generate OTP
  v_otp := public.generate_otp();
  
  -- Create donation offer
  INSERT INTO public.donations (
    request_id,
    donor_user_id,
    donor_type,
    otp_code,
    otp_expires_at,
    donor_name,
    donor_phone,
    donor_email
  ) VALUES (
    p_request_id,
    v_user_id,
    v_user_type,
    v_otp,
    NOW() + INTERVAL '24 hours',
    p_donor_name,
    p_donor_phone,
    p_donor_email
  ) RETURNING id INTO v_donation_id;
  
  RETURN QUERY SELECT TRUE, 'Donation offer created successfully'::TEXT, v_donation_id, v_otp;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 10. Grant permissions
-- ============================================
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT ALL ON public.donations TO authenticated;
GRANT EXECUTE ON FUNCTION public.generate_otp() TO authenticated;
GRANT EXECUTE ON FUNCTION public.verify_donation_otp(UUID, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.create_donation_offer(UUID, TEXT, TEXT, TEXT) TO authenticated;
