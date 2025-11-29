import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../donation/presentation/widgets/donation_widgets.dart';
import '../../../donor/domain/entities/blood_request_entity.dart';
import '../cubit/hospital_cubit.dart';

/// Hospital donation page - when hospital wants to donate to another hospital's request
/// Uses the same donation flow as Donor
class HospitalDonationPage extends StatelessWidget {
  final BloodRequestEntity request;

  const HospitalDonationPage({super.key, required this.request});

  DonorInfo? _getDonorInfo(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final hospitalCubit = context.read<HospitalCubit>();

    if (authState is AuthAuthenticated && hospitalCubit.profile != null) {
      final profile = hospitalCubit.profile!;
      return DonorInfo(
        name: profile.name,
        phone: profile.mobile,
        email: authState.user.email,
        donorType: 'hospital',
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final donorInfo = _getDonorInfo(context);

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
      body: donorInfo == null
          ? const Center(child: Text('Please complete your profile first'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Request Info Card
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

                  // Donation section based on status
                  if (request.status.value == 'completed')
                    const RequestCompletedWidget()
                  else if (request.status.value == 'pending')
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
    );
  }
}
