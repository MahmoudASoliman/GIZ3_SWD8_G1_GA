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
import '../cubit/hospital_cubit.dart';
import 'hospital_requests_page.dart';
import 'hospital_profile_page.dart';

/// Hospital home page with bottom navigation
class HospitalHomePage extends StatelessWidget {
  const HospitalHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<HospitalCubit>()),
        BlocProvider(create: (_) => getIt<AuthCubit>()..checkAuthStatus()),
        BlocProvider(create: (_) => getIt<NotificationsCubit>()),
      ],
      child: const _HospitalHomeContent(),
    );
  }
}

class _HospitalHomeContent extends StatefulWidget {
  const _HospitalHomeContent();

  @override
  State<_HospitalHomeContent> createState() => _HospitalHomeContentState();
}

class _HospitalHomeContentState extends State<_HospitalHomeContent> {
  int _selectedIndex = 0;
  int _initialRequestsTab = 0; // 0 = My Requests, 1 = Other Requests

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
    setState(() {
      _initialRequestsTab = 0; // My Requests tab
      _selectedIndex = 1;
    });
  }

  void _goToOtherRequestsTab() {
    setState(() {
      _initialRequestsTab = 1; // Other Requests tab
      _selectedIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        String userName = 'Hospital';
        if (authState is AuthAuthenticated) {
          userName = authState.user.email.split('@').first;
        }

        return BlocBuilder<NotificationsCubit, NotificationsState>(
          builder: (context, notifState) {
            int unreadCount = 0;
            if (notifState is NotificationsLoaded) {
              unreadCount = notifState.unreadCount;
            }

            final pages = [
              CustomHomeScreen(
                userName: userName,
                userType: UserType.hospital,
                unreadNotificationsCount: unreadCount,
                onPrimaryButtonPressed: _goToRequestsTab,
                onSecondaryButtonPressed: _goToOtherRequestsTab,
              ),
              HospitalRequestsPage(initialTabIndex: _initialRequestsTab),
              const HospitalProfilePage(),
            ];

            return Scaffold(
              backgroundColor: AppColors.white,
              body: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: pages[_selectedIndex],
              ),
              bottomNavigationBar: CustomBottomNavBar(
                currentIndex: _selectedIndex,
                onTap: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                  // Refresh notifications when coming back to home
                  if (index == 0) {
                    _loadNotificationsCount();
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
