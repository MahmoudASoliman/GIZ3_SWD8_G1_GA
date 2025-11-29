import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_profile_header.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../cubit/donor_cubit.dart';
import '../cubit/donor_state.dart';

/// Donor profile page - Original UI with backend integration
class DonorProfilePage extends StatefulWidget {
  const DonorProfilePage({super.key});

  @override
  State<DonorProfilePage> createState() => _DonorProfilePageState();
}

class _DonorProfilePageState extends State<DonorProfilePage> {
  bool _profileLoadAttempted = false;

  void _loadProfileIfNeeded() {
    if (_profileLoadAttempted) return;

    final authState = context.read<AuthCubit>().state;

    if (authState is AuthAuthenticated) {
      _profileLoadAttempted = true;
      context.read<DonorCubit>().loadProfile(authState.user.id);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadProfileIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, authState) {
          if (authState is AuthAuthenticated) {
            _loadProfileIfNeeded();
          }
        },
        child: BlocConsumer<DonorCubit, DonorState>(
          listener: (context, state) {
            if (state is DonorError) {
              // If no profile exists, navigate to create profile
              if (state.message.contains('0 rows') ||
                  state.message.contains('single JSON object')) {
                context.go('/donor-profile-setup');
              }
            }
          },
          builder: (context, state) {
            // Handle initial state - wait for auth then load
            if (state is DonorInitial) {
              final authState = context.read<AuthCubit>().state;
              if (authState is AuthAuthenticated && !_profileLoadAttempted) {
                _profileLoadAttempted = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.read<DonorCubit>().loadProfile(authState.user.id);
                });
              }
              return const Center(
                child: CircularProgressIndicator(color: AppColors.red),
              );
            }

            if (state is DonorLoading) {
              return _LoadingWithLogout(
                onLogout: () {
                  context.read<AuthCubit>().logout();
                  context.go('/auth');
                },
              );
            }

            if (state is DonorError) {
              if (state.message.contains('0 rows') ||
                  state.message.contains('single JSON object')) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.red),
                );
              }
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          _profileLoadAttempted = false;
                          final authState = context.read<AuthCubit>().state;
                          if (authState is AuthAuthenticated) {
                            context.read<DonorCubit>().loadProfile(
                              authState.user.id,
                            );
                          }
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Logout button for JWT expired or auth errors
                      OutlinedButton.icon(
                        onPressed: () {
                          context.read<AuthCubit>().logout();
                          context.go('/auth');
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout & Re-login'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.red,
                          side: const BorderSide(color: AppColors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is DonorProfileLoaded ||
                state is DonorProfileUpdated ||
                state is DonorProfileCreated) {
              final profile = state is DonorProfileLoaded
                  ? state.profile
                  : state is DonorProfileUpdated
                  ? state.profile
                  : (state as DonorProfileCreated).profile;

              return SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // Header
                      ProfileHeader(
                        imageWidget: const Image(
                          image: AssetImage('assets/Person.png'),
                        ),
                        labelText: profile.fullName,
                        backgroundColor: AppColors.lightRed,
                      ),

                      const SizedBox(height: 35),

                      const Padding(
                        padding: EdgeInsets.only(left: 20.0, bottom: 8.0),
                        child: Text(
                          'About',
                          style: TextStyle(
                            color: AppColors.red,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Container(
                            width: 160,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(21),
                              color: AppColors.lightRed,
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Blood Group',
                                    style: AppTextStyles.infoTextStyle,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Age',
                                    style: AppTextStyles.infoTextStyle,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Gender',
                                    style: AppTextStyles.infoTextStyle,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Governorate',
                                    style: AppTextStyles.infoTextStyle,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'City',
                                    style: AppTextStyles.infoTextStyle,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Mobile Number',
                                    style: AppTextStyles.infoTextStyle,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  profile.bloodGroup,
                                  style: AppTextStyles.infoTextStyle,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '${profile.age}',
                                  style: AppTextStyles.infoTextStyle,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  profile.gender,
                                  style: AppTextStyles.infoTextStyle,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  profile.governate,
                                  style: AppTextStyles.infoTextStyle,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  profile.city,
                                  style: AppTextStyles.infoTextStyle,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  profile.mobile,
                                  style: AppTextStyles.infoTextStyle,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),
                      const Center(
                        child: Image(image: AssetImage('assets/logo.png')),
                      ),
                      const SizedBox(height: 30),

                      // Logout Button
                      Center(
                        child: CustomElevatedButton(
                          width: 170,
                          onPressed: () {
                            context.read<AuthCubit>().logout();
                            context.go('/auth');
                          },
                          child: const Text(
                            'LogOut',
                            style: AppTextStyles.buttonTextStyle,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              );
            }

            return const Center(child: Text('Loading...'));
          },
        ),
      ),
    );
  }
}

/// Loading widget with logout button that appears after a delay
class _LoadingWithLogout extends StatefulWidget {
  final VoidCallback onLogout;

  const _LoadingWithLogout({required this.onLogout});

  @override
  State<_LoadingWithLogout> createState() => _LoadingWithLogoutState();
}

class _LoadingWithLogoutState extends State<_LoadingWithLogout> {
  bool _showLogout = false;

  @override
  void initState() {
    super.initState();
    // Show logout button after 5 seconds of loading
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showLogout = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.red),
          const SizedBox(height: 16),
          const Text('Loading profile...'),
          if (_showLogout) ...[
            const SizedBox(height: 24),
            const Text(
              'Taking too long?',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: widget.onLogout,
              icon: const Icon(Icons.logout),
              label: const Text('Logout & Re-login'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.red,
                side: const BorderSide(color: AppColors.red),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
