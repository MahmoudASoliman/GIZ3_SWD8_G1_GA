import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/di/injection.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/api_constants.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Validate environment configuration
  if (!ApiConstants.isConfigured) {
    runApp(const _ConfigurationErrorApp());
    return;
  }

  try {
    await Firebase.initializeApp();
  } catch (e) {
    // Firebase initialization failed silently in development mode
    // Run 'flutterfire configure' to setup properly
  }

  // Set background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize Supabase
  await Supabase.initialize(
    url: ApiConstants.supabaseUrl,
    anonKey: ApiConstants.supabaseAnonKey,
  );

  // Setup Dependency Injection
  await configureDependencies();

  // Initialize Notification Service
  final notificationService = getIt<NotificationService>();
  await notificationService.initialize();

  // Listen for auth state changes
  Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
    final event = data.event;

    // Save FCM token on sign in or token refresh
    if (event == AuthChangeEvent.signedIn ||
        event == AuthChangeEvent.tokenRefreshed) {
      try {
        await notificationService.saveTokenForCurrentUser();
      } catch (e) {
        // Error saving FCM token silently handled
      }
    }

    // Handle JWT expiry - redirect to login
    if (event == AuthChangeEvent.signedOut) {
      // Navigate to auth page when session expires
      appRouter.go('/auth');
    }
  });

  runApp(const MainApp());
}

/// App shown when environment variables are not configured
class _ConfigurationErrorApp extends StatelessWidget {
  const _ConfigurationErrorApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Configuration Error',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Environment variables are not configured.\n\n'
                  'Please run the app with:\n'
                  'flutter run --dart-define=SUPABASE_URL=your_url '
                  '--dart-define=SUPABASE_ANON_KEY=your_key',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Blood Donation App',
      theme: ThemeData(
        primaryColor: AppColors.red,
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      routerConfig: appRouter,
    );
  }
}
