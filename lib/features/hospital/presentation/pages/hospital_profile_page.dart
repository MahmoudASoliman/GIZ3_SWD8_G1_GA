import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_profile_header.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../cubit/hospital_cubit.dart';
import '../cubit/hospital_state.dart';
import 'hospital_profile_setup_page.dart';

/// Hospital profile page
class HospitalProfilePage extends StatefulWidget {
  const HospitalProfilePage({super.key});

  @override
  State<HospitalProfilePage> createState() => _HospitalProfilePageState();
}

class _HospitalProfilePageState extends State<HospitalProfilePage> {
  bool _isFirstLoad = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isFirstLoad) {
      _isFirstLoad = false;
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthAuthenticated) {
        context.read<HospitalCubit>().loadProfile(authState.user.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, authState) {
        if (authState is AuthUnauthenticated) {
          context.go('/auth');
        }
      },
      builder: (context, authState) {
        return BlocConsumer<HospitalCubit, HospitalState>(
          listener: (context, state) {
            if (state is HospitalError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            if (state is HospitalLoading) {
              return const LoadingWidget(message: 'Loading profile...');
            }

            // Check if profile not found - show create profile form
            if (state is HospitalError &&
                state.message.toLowerCase().contains('not found')) {
              return const HospitalProfileSetupPage();
            }

            if (state is HospitalError) {
              return ErrorDisplayWidget(
                message: state.message,
                onRetry: () {
                  final authState = context.read<AuthCubit>().state;
                  if (authState is AuthAuthenticated) {
                    context.read<HospitalCubit>().loadProfile(
                      authState.user.id,
                    );
                  }
                },
              );
            }

            if (state is HospitalProfileLoaded ||
                state is HospitalProfileCreated) {
              final profile = state is HospitalProfileLoaded
                  ? state.profile
                  : (state as HospitalProfileCreated).profile;

              return _buildProfileView(context, profile);
            }

            // Default - show create profile form
            return const HospitalProfileSetupPage();
          },
        );
      },
    );
  }

  Widget _buildProfileView(BuildContext context, dynamic profile) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              ProfileHeader(
                imageWidget: const Image(image: AssetImage('assets/H.png')),
                labelText: profile.name,
                backgroundColor: AppColors.lightRed,
              ),
              const SizedBox(height: 49),

              const Padding(
                padding: EdgeInsets.only(left: 50.0, bottom: 8.0),
                child: Text(
                  'About',
                  style: TextStyle(
                    color: AppColors.red,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),

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
                            'Governorate',
                            style: AppTextStyles.infoTextStyle,
                          ),
                          SizedBox(height: 10),
                          Text('City', style: AppTextStyles.infoTextStyle),
                          SizedBox(height: 10),
                          Text(
                            'Mobile Number',
                            style: AppTextStyles.infoTextStyle,
                          ),
                          SizedBox(height: 10),
                          Text('Email', style: AppTextStyles.infoTextStyle),
                          SizedBox(height: 10),
                          Text(
                            'Location Link',
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
                          profile.governate,
                          style: AppTextStyles.infoTextStyle,
                        ),
                        const SizedBox(height: 10),
                        Text(profile.city, style: AppTextStyles.infoTextStyle),
                        const SizedBox(height: 10),
                        Text(
                          profile.mobile,
                          style: AppTextStyles.infoTextStyle,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          profile.address,
                          style: AppTextStyles.infoTextStyle,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'View Location',
                          style: AppTextStyles.infoTextStyle,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 23),
              const Center(child: Image(image: AssetImage('assets/logo.png'))),
              const SizedBox(height: 23),

              Center(
                child: CustomElevatedButton(
                  onPressed: () {
                    context.read<AuthCubit>().logout();
                  },
                  width: 166,
                  child: const Text(
                    'LogOut',
                    style: AppTextStyles.buttonTextStyle,
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
