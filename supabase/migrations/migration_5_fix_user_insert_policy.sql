-- Fix: Allow trigger to insert into users table
-- This policy allows the handle_new_user() function (SECURITY DEFINER) to insert

-- Drop old policy if exists
DROP POLICY IF EXISTS "Users can insert own data" ON public.users;

-- Create new policy that allows both direct user insert and trigger insert
CREATE POLICY "Users can insert own data"
  ON public.users
  FOR INSERT
  WITH CHECK (
    auth.uid() = id  -- Direct user insert
    OR 
    auth.role() = 'authenticated'  -- Allow authenticated inserts (from trigger)
  );

-- Alternative: Create separate policy for service role (more secure)
DROP POLICY IF EXISTS "Service role can insert users" ON public.users;
CREATE POLICY "Service role can insert users"
  ON public.users
  FOR INSERT
  WITH CHECK (true);  -- Service role bypasses RLS anyway

-- Grant necessary permissions to authenticated role
GRANT INSERT ON public.users TO authenticated;
GRANT INSERT ON public.users TO service_role;
