-- Migration: Enable HTTP extension for external API calls
-- Created: 2025-01-01
-- Description: Enables pg_net extension for calling Edge Functions from triggers

-- Enable pg_net extension for HTTP requests
CREATE EXTENSION IF NOT EXISTS pg_net;

-- Grant usage to authenticated users
GRANT USAGE ON SCHEMA net TO authenticated;
GRANT USAGE ON SCHEMA net TO service_role;

-- Note: pg_net is used by triggers to call Edge Functions
-- Example: Sending FCM notifications when new blood request is created
