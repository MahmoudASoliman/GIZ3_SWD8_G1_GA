-- ============================================
-- Migration 7: Fix ALL missing columns to match Flutter code
-- Created: 2025-01-07
-- Description: Adds all missing columns that the Flutter app expects
-- ============================================

-- ============================================
-- 1. FIX DONORS TABLE
-- ============================================

-- Add 'mobile' column (the code expects this)
ALTER TABLE public.donors 
ADD COLUMN IF NOT EXISTS mobile TEXT;

-- Add gender column
ALTER TABLE public.donors 
ADD COLUMN IF NOT EXISTS gender TEXT CHECK (gender IN ('Male', 'Female'));

-- Make phone_number nullable (since we use mobile now)
ALTER TABLE public.donors 
ALTER COLUMN phone_number DROP NOT NULL;

-- ============================================
-- 2. FIX HOSPITALS TABLE  
-- ============================================

-- Add 'mobile' column
ALTER TABLE public.hospitals 
ADD COLUMN IF NOT EXISTS mobile TEXT;

-- Make phone_number nullable (since we use mobile now)
ALTER TABLE public.hospitals 
ALTER COLUMN phone_number DROP NOT NULL;

-- ============================================
-- 3. FIX BLOOD_REQUESTS TABLE
-- ============================================

-- The code expects 'hospital_name' column
ALTER TABLE public.blood_requests 
ADD COLUMN IF NOT EXISTS hospital_name TEXT;

-- The code expects 'companion_mobile' column
ALTER TABLE public.blood_requests 
ADD COLUMN IF NOT EXISTS companion_mobile TEXT;

-- ============================================
-- 4. CREATE INDEXES
-- ============================================

CREATE INDEX IF NOT EXISTS idx_donors_gender ON public.donors(gender);
CREATE INDEX IF NOT EXISTS idx_donors_mobile ON public.donors(mobile);
CREATE INDEX IF NOT EXISTS idx_hospitals_mobile ON public.hospitals(mobile);

-- ============================================
-- 5. ADD COMMENTS
-- ============================================

COMMENT ON COLUMN public.donors.gender IS 'Donor gender: Male or Female';
COMMENT ON COLUMN public.donors.mobile IS 'Donor mobile phone number';
COMMENT ON COLUMN public.hospitals.mobile IS 'Hospital contact mobile number';
COMMENT ON COLUMN public.blood_requests.hospital_name IS 'Name of the hospital making the request';
COMMENT ON COLUMN public.blood_requests.companion_mobile IS 'Mobile number of patient companion';

