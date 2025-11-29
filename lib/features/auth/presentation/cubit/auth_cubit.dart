import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/constants/enums.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/google_signin_usecase.dart';
import 'auth_state.dart';

@injectable
class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final SignUpUseCase signUpUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final GoogleSignInUseCase googleSignInUseCase;

  AuthCubit({
    required this.loginUseCase,
    required this.signUpUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    required this.googleSignInUseCase,
  }) : super(const AuthInitial());

  /// Check if user is already logged in
  Future<void> checkAuthStatus() async {
    emit(const AuthLoading());

    final result = await getCurrentUserUseCase(const NoParams());

    result.fold((failure) => emit(const AuthUnauthenticated()), (user) {
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthUnauthenticated());
      }
    });
  }

  /// Login
  Future<void> login({
    required String email,
    required String password,
    UserType? expectedUserType,
  }) async {
    emit(const AuthLoading());

    final result = await loginUseCase(
      LoginParams(email: email, password: password),
    );

    result.fold((failure) => emit(AuthError(failure.message)), (user) {
      // Validate user type if expected type is provided
      if (expectedUserType != null && user.userType != expectedUserType) {
        final expectedLabel = expectedUserType == UserType.donor
            ? 'Donor'
            : 'Hospital';
        final actualLabel = user.userType == UserType.donor
            ? 'Donor'
            : 'Hospital';
        emit(
          AuthError(
            'This account is registered as $actualLabel, not $expectedLabel.\n\nPlease select the correct account type or use a different account.',
          ),
        );
        return;
      }
      emit(AuthAuthenticated(user));
    });
  }

  /// Sign up
  Future<void> signUp({
    required String email,
    required String password,
    required UserType userType,
  }) async {
    emit(const AuthLoading());

    final result = await signUpUseCase(
      SignUpParams(email: email, password: password, userType: userType),
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  /// Logout
  Future<void> logout() async {
    if (isClosed) return;
    emit(const AuthLoading());

    final result = await logoutUseCase(const NoParams());

    if (isClosed) return;
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }

  /// Google Sign-In
  Future<void> signInWithGoogle() async {
    emit(const AuthLoading());

    final result = await googleSignInUseCase(const NoParams());

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }
}
