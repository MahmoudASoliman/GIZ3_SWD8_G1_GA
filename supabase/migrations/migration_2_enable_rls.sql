-- Migration: Enable Row Level Security (RLS)
-- Created: 2025-01-01
-- Description: Enables RLS and creates security policies for all tables

-- ============================================
-- 1. Enable RLS on all tables
-- ============================================
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.donors ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.hospitals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.blood_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- ============================================
-- 2. Users table policies
-- ============================================

-- Users can read their own data
CREATE POLICY "Users can read own data"
  ON public.users
  FOR SELECT
  USING (auth.uid() = id);

-- Users can update their own data
CREATE POLICY "Users can update own data"
  ON public.users
  FOR UPDATE
  USING (auth.uid() = id);

-- Users can insert their own data (during signup)
CREATE POLICY "Users can insert own data"
  ON public.users
  FOR INSERT
  WITH CHECK (auth.uid() = id);

-- ============================================
-- 3. Donors table policies
-- ============================================

-- Anyone can read all donors (for matching)
CREATE POLICY "Anyone can read donors"
  ON public.donors
  FOR SELECT
  USING (true);

-- Donors can insert their own profile
CREATE POLICY "Donors can insert own profile"
  ON public.donors
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Donors can update their own profile
CREATE POLICY "Donors can update own profile"
  ON public.donors
  FOR UPDATE
  USING (auth.uid() = user_id);

-- Donors can delete their own profile
CREATE POLICY "Donors can delete own profile"
  ON public.donors
  FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================
-- 4. Hospitals table policies
-- ============================================

-- Anyone can read all hospitals
CREATE POLICY "Anyone can read hospitals"
  ON public.hospitals
  FOR SELECT
  USING (true);

-- Hospitals can insert their own profile
CREATE POLICY "Hospitals can insert own profile"
  ON public.hospitals
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Hospitals can update their own profile
CREATE POLICY "Hospitals can update own profile"
  ON public.hospitals
  FOR UPDATE
  USING (auth.uid() = user_id);

-- Hospitals can delete their own profile
CREATE POLICY "Hospitals can delete own profile"
  ON public.hospitals
  FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================
-- 5. Blood requests table policies
-- ============================================

-- Anyone can read all blood requests
CREATE POLICY "Anyone can read blood requests"
  ON public.blood_requests
  FOR SELECT
  USING (true);

-- Only hospitals can create requests
CREATE POLICY "Hospitals can create requests"
  ON public.blood_requests
  FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.hospitals
      WHERE user_id = auth.uid() AND id = hospital_id
    )
  );

-- Hospitals can update their own requests
CREATE POLICY "Hospitals can update own requests"
  ON public.blood_requests
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.hospitals
      WHERE user_id = auth.uid() AND id = hospital_id
    )
  );

-- Donors can update requests they accepted (to mark as completed)
CREATE POLICY "Donors can update accepted requests"
  ON public.blood_requests
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.donors
      WHERE user_id = auth.uid() AND id = accepted_by
    )
  );

-- Hospitals can delete their own requests
CREATE POLICY "Hospitals can delete own requests"
  ON public.blood_requests
  FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM public.hospitals
      WHERE user_id = auth.uid() AND id = hospital_id
    )
  );

-- ============================================
-- 6. Notifications table policies
-- ============================================

-- Users can read their own notifications
CREATE POLICY "Users can read own notifications"
  ON public.notifications
  FOR SELECT
  USING (auth.uid() = user_id);

-- Users can update their own notifications (mark as read)
CREATE POLICY "Users can update own notifications"
  ON public.notifications
  FOR UPDATE
  USING (auth.uid() = user_id);

-- System can insert notifications (via service role)
CREATE POLICY "System can insert notifications"
  ON public.notifications
  FOR INSERT
  WITH CHECK (true);

-- Users can delete their own notifications
CREATE POLICY "Users can delete own notifications"
  ON public.notifications
  FOR DELETE
  USING (auth.uid() = user_id);
