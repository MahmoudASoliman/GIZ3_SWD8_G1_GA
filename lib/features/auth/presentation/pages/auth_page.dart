import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import 'login_page.dart';
import 'signup_page.dart';

/// Main Auth Page with Login/SignUp tabs
class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthCubit>(),
      child: const AuthView(),
    );
  }
}

class AuthView extends StatelessWidget {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        // Close any loading dialogs
        if (state is! AuthLoading) {
          // Try to pop loading dialog if exists
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        }

        if (state is AuthError) {
          CustomSnackBar.showError(context, state.message);
        } else if (state is AuthAuthenticated) {
          // Navigate based on user type
          final userType = state.user.userType.value;
          if (userType == 'donor') {
            context.go('/donor-home');
          } else if (userType == 'hospital') {
            context.go('/hospital-home');
          }
        }
      },
      child: const _AuthPageContent(),
    );
  }
}

class _AuthPageContent extends StatefulWidget {
  const _AuthPageContent();

  @override
  State<_AuthPageContent> createState() => _AuthPageContentState();
}

class _AuthPageContentState extends State<_AuthPageContent> {
  bool _isLogin = true;

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 60),

                // Tab Headers
                Row(
                  children: [
                    Expanded(
                      child: _TabHeader(
                        title: AppStrings.login,
                        isActive: _isLogin,
                        onTap: () => setState(() => _isLogin = true),
                      ),
                    ),
                    Expanded(
                      child: _TabHeader(
                        title: AppStrings.signUp,
                        isActive: !_isLogin,
                        onTap: () => setState(() => _isLogin = false),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Content
                AnimatedSwitcher(
                  duration: Duration.zero,
                  child: _isLogin
                      ? LoginPage(
                          key: const ValueKey(1),
                          onTapSignUp: _toggleAuthMode,
                        )
                      : SignUpPage(
                          key: const ValueKey(2),
                          onTapLogin: _toggleAuthMode,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabHeader extends StatelessWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const _TabHeader({
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: isActive ? AppColors.red : Colors.grey,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              fontFamily: 'poppins',
            ),
          ),
          const SizedBox(height: 2),
          Container(
            height: 3,
            color: isActive ? AppColors.red : Colors.transparent,
          ),
        ],
      ),
    );
  }
}
