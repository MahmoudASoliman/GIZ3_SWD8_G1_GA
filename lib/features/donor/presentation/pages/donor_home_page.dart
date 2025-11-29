import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/custom_bottom_nav_bar.dart';
import '../../../../core/widgets/custom_home_screen.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../notifications/presentation/cubit/notifications_cubit.dart';
import '../../../notifications/presentation/cubit/notifications_state.dart';
import '../cubit/donor_cubit.dart';
import 'donor_requests_page.dart';
import 'donor_profile_page.dart';

/// Donor home page with bottom navigation
class DonorHomePage extends StatelessWidget {
  const DonorHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<DonorCubit>()),
        BlocProvider(create: (_) => getIt<AuthCubit>()..checkAuthStatus()),
        BlocProvider(create: (_) => getIt<NotificationsCubit>()),
      ],
      child: const _DonorHomeContent(),
    );
  }
}

class _DonorHomeContent extends StatefulWidget {
  const _DonorHomeContent();

  @override
  State<_DonorHomeContent> createState() => _DonorHomeContentState();
}

class _DonorHomeContentState extends State<_DonorHomeContent> {
  int _currentIndex = 0;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationsCount();
  }

  void _loadNotificationsCount() {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      context.read<NotificationsCubit>().loadNotifications(userId);
    }
  }

  void _goToRequestsTab() {
    setState(() => _currentIndex = 1);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        String userName = 'User';
        if (authState is AuthAuthenticated) {
          userName = authState.user.email.split('@').first;
        }

        return BlocBuilder<NotificationsCubit, NotificationsState>(
          builder: (context, notifState) {
            int unreadCount = 0;
            if (notifState is NotificationsLoaded) {
              unreadCount = notifState.unreadCount;
            }

            final screens = [
              CustomHomeScreen(
                userName: userName,
                userType: UserType.donor,
                unreadNotificationsCount: unreadCount,
                onPrimaryButtonPressed: _goToRequestsTab,
              ),
              const DonorRequestsPage(),
            ];

            return Scaffold(
              backgroundColor: AppColors.white,
              body: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: screens[_currentIndex],
              ),
              bottomNavigationBar: CustomBottomNavBar(
                currentIndex: _currentIndex,
                onTap: (index) async {
                  if (index == 2) {
                    if (_isNavigating) return;
                    _isNavigating = true;

                    final donorCubit = context.read<DonorCubit>();
                    final authCubit = context.read<AuthCubit>();

                    final currentAuthState = authCubit.state;
                    if (currentAuthState is! AuthAuthenticated) {
                      await authCubit.checkAuthStatus();
                    }

                    if (!context.mounted) return;
                    await Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, a1, a2) => MultiBlocProvider(
                          providers: [
                            BlocProvider.value(value: donorCubit),
                            BlocProvider.value(value: authCubit),
                          ],
                          child: const DonorProfilePage(),
                        ),
                        transitionsBuilder: (_, animation, __, child) {
                          return SlideTransition(
                            position: Tween(
                              begin: const Offset(1, 0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          );
                        },
                      ),
                    );

                    _isNavigating = false;
                    // Refresh notifications count when returning
                    _loadNotificationsCount();
                  } else {
                    setState(() => _currentIndex = index);
                  }
                },
                items: const [
                  CustomNavItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home,
                    label: 'Home',
                  ),
                  CustomNavItem(
                    icon: Icons.favorite_border,
                    activeIcon: Icons.favorite,
                    label: 'Requests',
                  ),
                  CustomNavItem(
                    icon: Icons.person_outline,
                    activeIcon: Icons.person,
                    label: 'Profile',
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
