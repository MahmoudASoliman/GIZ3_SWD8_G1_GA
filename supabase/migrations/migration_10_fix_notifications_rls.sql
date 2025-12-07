-- Migration: Fix notifications RLS for insert
-- Allow any authenticated user to insert notifications

-- Drop existing insert policy if it exists
DROP POLICY IF EXISTS "System can insert notifications" ON public.notifications;

-- Create new policy that allows any authenticated user to insert
CREATE POLICY "Anyone can insert notifications"
  ON public.notifications
  FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

-- Also allow inserting notifications for other users (for system notifications)
-- This is needed when a donor completes donation and needs to notify hospital
CREATE POLICY "Authenticated users can insert notifications for others"
  ON public.notifications
  FOR INSERT
  WITH CHECK (true);
