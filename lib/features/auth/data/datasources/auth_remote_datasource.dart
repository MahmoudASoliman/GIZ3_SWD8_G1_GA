import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart' as app_exceptions;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/enums.dart';
import '../models/user_model.dart';

/// Remote data source for authentication
abstract class AuthRemoteDataSource {
  Future<UserModel> signIn({required String email, required String password});

  Future<UserModel> signUp({
    required String email,
    required String password,
    required UserType userType,
  });

  Future<UserModel> signInWithGoogle();

  Future<void> signOut();

  Future<UserModel?> getCurrentUser();
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _supabase;

  AuthRemoteDataSourceImpl(this._supabase);

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw app_exceptions.AuthException('Login failed');
      }

      // Get user data from users table
      final userData = await _supabase
          .from(ApiConstants.usersTable)
          .select()
          .eq('id', response.user!.id)
          .single();

      return UserModel.fromJson(userData);
    } on app_exceptions.AuthException {
      rethrow;
    } catch (e) {
      throw app_exceptions.AuthException('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    required UserType userType,
  }) async {
    try {
      // Sign up with Supabase Auth and add user_type to metadata
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'user_type': userType.value},
      );

      if (response.user == null) {
        throw app_exceptions.AuthException('Signup failed');
      }

      // Wait a bit for the trigger to create the user record
      await Future.delayed(const Duration(milliseconds: 500));

      // Get created user from users table
      final userData = await _supabase
          .from(ApiConstants.usersTable)
          .select()
          .eq('id', response.user!.id)
          .maybeSingle();

      // If user not found (trigger didn't run yet or failed), return a temporary model
      if (userData == null) {
        return UserModel(
          id: response.user!.id,
          email: email,
          userType: userType,
          createdAt: DateTime.now(),
        );
      }

      return UserModel.fromJson(userData);
    } on AuthException catch (e) {
      // Handle specific Supabase auth errors
      final errorMessage = e.message.toLowerCase();

      if (errorMessage.contains('email rate limit') ||
          errorMessage.contains('60 seconds') ||
          errorMessage.contains('over_email_send_rate_limit')) {
        throw app_exceptions.AuthException(
          '⏱️ يرجى الانتظار دقيقة واحدة قبل المحاولة مرة أخرى\n\nلتجنب الإزعاج، يُسمح بمحاولة تسجيل واحدة كل دقيقة.',
        );
      } else if (errorMessage.contains('already registered') ||
          errorMessage.contains('already exists')) {
        throw app_exceptions.AuthException(
          '📧 البريد الإلكتروني مسجل بالفعل\n\nإذا كان هذا حسابك، يرجى تسجيل الدخول.',
        );
      } else if (errorMessage.contains('invalid email')) {
        throw app_exceptions.AuthException('❌ البريد الإلكتروني غير صحيح');
      } else if (errorMessage.contains('weak password')) {
        throw app_exceptions.AuthException(
          '🔒 كلمة المرور ضعيفة. يجب أن تكون 6 أحرف على الأقل',
        );
      }

      throw app_exceptions.AuthException('فشل التسجيل: ${e.message}');
    } on app_exceptions.AuthException {
      rethrow;
    } catch (e) {
      final errorStr = e.toString().toLowerCase();

      // Check for RLS policy violation
      if (errorStr.contains('row-level security') ||
          errorStr.contains('42501')) {
        throw app_exceptions.AuthException(
          '⚠️ حدث خطأ في الإعدادات\n\nيرجى التأكد من تطبيق جميع migrations في Supabase.',
        );
      }

      throw app_exceptions.AuthException('فشل التسجيل: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw app_exceptions.AuthException('Logout failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      // Supabase Google OAuth Sign-In
      final response = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutterquickstart://login-callback/',
      );

      if (!response) {
        throw app_exceptions.AuthException('Google Sign-In cancelled');
      }

      // Wait for auth state to update
      await Future.delayed(const Duration(seconds: 2));

      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw app_exceptions.AuthException('Google Sign-In failed');
      }

      // Check if user exists in users table
      var userData = await _supabase
          .from(ApiConstants.usersTable)
          .select()
          .eq('id', user.id)
          .maybeSingle();

      // If user doesn't exist, create new user record
      if (userData == null) {
        // Default to donor type for Google sign-in
        final newUser = {
          'id': user.id,
          'email': user.email!,
          'user_type': 'donor',
          'created_at': DateTime.now().toIso8601String(),
        };

        await _supabase.from(ApiConstants.usersTable).insert(newUser);
        userData = newUser;
      }

      return UserModel.fromJson(userData);
    } on app_exceptions.AuthException {
      rethrow;
    } catch (e) {
      throw app_exceptions.AuthException(
        'Google Sign-In failed: ${e.toString()}',
      );
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _supabase.auth.currentUser;

      if (user == null) return null;

      final userData = await _supabase
          .from(ApiConstants.usersTable)
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (userData == null) return null;

      return UserModel.fromJson(userData);
    } catch (e) {
      return null;
    }
  }
}
