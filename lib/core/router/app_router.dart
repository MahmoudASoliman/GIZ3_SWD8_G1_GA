import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../di/injection.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/auth_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/donor/presentation/pages/donor_home_page.dart';
import '../../features/donor/presentation/pages/donor_profile_setup_page.dart';
import '../../features/donor/presentation/pages/request_details_page.dart';
import '../../features/donor/presentation/cubit/donor_cubit.dart';
import '../../features/hospital/presentation/pages/hospital_home_page.dart';
import '../../features/hospital/presentation/pages/hospital_request_details_page.dart';
import '../../features/hospital/presentation/cubit/hospital_cubit.dart';
import '../../features/donation/presentation/cubit/donation_cubit.dart';
import '../../features/common/presentation/pages/blog1_screen.dart';
import '../../features/common/presentation/pages/blog2_screen.dart';
import '../../features/common/presentation/pages/blog3_screen.dart';
import '../../features/notifications/presentation/pages/notifications_screen.dart';

/// App router using GoRouter
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/auth',
      name: 'auth',
      builder: (context, state) => const AuthPage(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) =>
          LoginPage(onTapSignUp: () => context.go('/signup')),
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) =>
          SignUpPage(onTapLogin: () => context.go('/login')),
    ),
    GoRoute(
      path: '/donor-home',
      name: 'donorHome',
      builder: (context, state) => const DonorHomePage(),
    ),
    GoRoute(
      path: '/donor-profile-setup',
      name: 'donorProfileSetup',
      builder: (context, state) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => getIt<DonorCubit>()),
          BlocProvider(create: (_) => getIt<AuthCubit>()..checkAuthStatus()),
        ],
        child: const DonorProfileSetupPage(),
      ),
    ),
    GoRoute(
      path: '/hospital-home',
      name: 'hospitalHome',
      builder: (context, state) => const HospitalHomePage(),
    ),
    GoRoute(
      path: '/blog1',
      name: 'blog1',
      builder: (context, state) => const Blog1Screen(),
    ),
    GoRoute(
      path: '/blog2',
      name: 'blog2',
      builder: (context, state) => const Blog2Screen(),
    ),
    GoRoute(
      path: '/blog3',
      name: 'blog3',
      builder: (context, state) => const Blog3Screen(),
    ),
    GoRoute(
      path: '/notifications',
      name: 'notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/donor-request-details/:requestId',
      name: 'donorRequestDetails',
      builder: (context, state) {
        final requestId = state.pathParameters['requestId']!;
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => getIt<DonorCubit>()),
            BlocProvider(create: (_) => getIt<AuthCubit>()..checkAuthStatus()),
          ],
          child: RequestDetailsPage(requestId: requestId),
        );
      },
    ),
    GoRoute(
      path: '/hospital-request-details/:requestId',
      name: 'hospitalRequestDetails',
      builder: (context, state) {
        final requestId = state.pathParameters['requestId']!;
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => getIt<HospitalCubit>()),
            BlocProvider(create: (_) => getIt<DonationCubit>()),
          ],
          child: HospitalRequestDetailsPage(requestId: requestId),
        );
      },
    ),
  ],
  errorBuilder: (context, state) =>
      Scaffold(body: Center(child: Text('Page not found: ${state.uri.path}'))),
);
