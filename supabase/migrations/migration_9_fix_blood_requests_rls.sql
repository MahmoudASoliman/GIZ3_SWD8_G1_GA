-- ============================================
-- Migration 9: Fix blood_requests RLS policies
-- Created: 2025-11-28
-- Description: Fix RLS to check hospital ownership via hospitals table
-- ============================================

-- Drop existing policies
DROP POLICY IF EXISTS "Hospitals can create requests" ON public.blood_requests;
DROP POLICY IF EXISTS "Hospitals can update own requests" ON public.blood_requests;
DROP POLICY IF EXISTS "Hospitals can delete own requests" ON public.blood_requests;

-- ============================================
-- RECREATE POLICIES - check ownership via hospitals.user_id
-- ============================================

-- Hospitals can create requests
-- hospital_id must exist in hospitals table and belong to current user
CREATE POLICY "Hospitals can create requests"
  ON public.blood_requests
  FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.hospitals h
      WHERE h.id = hospital_id 
      AND h.user_id = auth.uid()
    )
  );

-- Hospitals can update their own requests
CREATE POLICY "Hospitals can update own requests"
  ON public.blood_requests
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.hospitals h
      WHERE h.id = hospital_id 
      AND h.user_id = auth.uid()
    )
  );

-- Hospitals can delete their own requests
CREATE POLICY "Hospitals can delete own requests"
  ON public.blood_requests
  FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM public.hospitals h
      WHERE h.id = hospital_id 
      AND h.user_id = auth.uid()
    )
  );

-- ============================================
-- Anyone can read blood requests
-- ============================================
DROP POLICY IF EXISTS "Anyone can read blood requests" ON public.blood_requests;

CREATE POLICY "Anyone can read blood requests"
  ON public.blood_requests
  FOR SELECT
  USING (true);
