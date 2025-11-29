import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../donation/presentation/widgets/donation_widgets.dart';
import '../cubit/donor_cubit.dart';
import '../cubit/donor_state.dart';

/// Request details page - shows full details of a blood request
/// Uses shared donation widgets for consistency with Hospital
class RequestDetailsPage extends StatefulWidget {
  final String requestId;

  const RequestDetailsPage({super.key, required this.requestId});

  @override
  State<RequestDetailsPage> createState() => _RequestDetailsPageState();
}

class _RequestDetailsPageState extends State<RequestDetailsPage> {
  @override
  void initState() {
    super.initState();
    // Load request details
    context.read<DonorCubit>().loadRequestDetails(widget.requestId);

    // Load donor profile if not already loaded
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      final donorCubit = context.read<DonorCubit>();
      if (donorCubit.profile == null) {
        donorCubit.loadProfile(authState.user.id);
      }
    }
  }

  DonorInfo? _getDonorInfo() {
    final authState = context.read<AuthCubit>().state;
    final donorCubit = context.read<DonorCubit>();

    if (authState is AuthAuthenticated && donorCubit.profile != null) {
      final profile = donorCubit.profile!;
      return DonorInfo(
        name: profile.fullName,
        phone: profile.mobile,
        email: authState.user.email,
        donorType: 'donor',
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.grey),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppStrings.requestDetails,
          style: const TextStyle(
            color: AppColors.red,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: BlocConsumer<DonorCubit, DonorState>(
        listener: (context, state) {
          if (state is DonorRequestAccepted) {
            CustomSnackBar.showSuccess(context, state.message);
            Navigator.pop(context);
          } else if (state is DonorError) {
            CustomSnackBar.showError(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is DonorLoading) {
            return const LoadingWidget(message: 'Loading details...');
          }

          if (state is DonorError) {
            return ErrorDisplayWidget(
              message: state.message,
              onRetry: () {
                context.read<DonorCubit>().loadRequestDetails(widget.requestId);
              },
            );
          }

          if (state is DonorRequestDetailsLoaded) {
            final request = state.request;
            final donorInfo = _getDonorInfo();

            return LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                final isWideScreen = screenWidth > 600;
                final horizontalPadding = isWideScreen
                    ? screenWidth * 0.1
                    : 20.0;

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 20,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Request Info Card - Using shared widget (includes header)
                          RequestInfoCard(
                            requestId: request.id,
                            patientName: request.patientName,
                            bloodGroup: request.bloodGroup,
                            roomNumber: request.roomNumber,
                            companionMobile: request.companionMobile,
                            hospitalName: request.hospitalName,
                            governate: request.governate,
                            city: request.city,
                            status: request.status.value,
                          ),
                          const SizedBox(height: 32),

                          // Donation Section - Using shared widget
                          if (request.status.value == 'completed')
                            const Center(child: RequestCompletedWidget())
                          else if (request.status.value == 'pending' &&
                              donorInfo != null)
                            DonationSection(
                              requestId: request.id,
                              patientName: request.patientName,
                              bloodGroup: request.bloodGroup,
                              hospitalName: request.hospitalName,
                              companionMobile: request.companionMobile,
                              donorInfo: donorInfo,
                              onDonationComplete: () => Navigator.pop(context),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }

          return const Center(child: Text('No request details'));
        },
      ),
    );
  }
}
