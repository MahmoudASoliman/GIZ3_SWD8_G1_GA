import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/constants/enums.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthCubit>()..checkAuthStatus(),
      child: const SplashView(),
    );
  }
}

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Navigate based on user type
          if (state.user.userType == UserType.donor) {
            context.go('/donor-home');
          } else {
            context.go('/hospital-home');
          }
        } else if (state is AuthUnauthenticated) {
          // Navigate to Auth Page
          context.go('/auth');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.lightRed,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset('assets/reversed_logo.png', height: 150),
              const SizedBox(height: 24),
              const CircularProgressIndicator(color: AppColors.red),
            ],
          ),
        ),
      ),
    );
  }
}
