/// API endpoints and constants
///
/// IMPORTANT: To run the app, provide environment variables:
/// flutter run --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_ANON_KEY=your_key
///
/// Or create a .env file and use flutter_dotenv package
class ApiConstants {
  // Supabase - Values MUST be provided via --dart-define
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://bnudywtsjvjluxgmmhun.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJudWR5d3RzanZqbHV4Z21taHVuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQyODM2OTYsImV4cCI6MjA3OTg1OTY5Nn0.i7CHxiy5JzRixdzoAPJeuXM_vKbVzjIwr9GylfHvxjQ',
  );

  /// Validates that all required environment variables are set
  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  // Tables
  static const String usersTable = 'users';
  static const String donorsTable = 'donors';
  static const String hospitalsTable = 'hospitals';
  static const String requestsTable = 'blood_requests';
  static const String notificationsTable = 'notifications';

  // Edge Functions
  static const String sendNotificationFunction = 'send-fcm-notification';
  static const String notifyDonorsFunction = 'notify-donors';
  static const String notifyHospitalFunction = 'notify-hospital';
}
