import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../domain/entities/donation.dart';
import '../cubit/donation_cubit.dart';
import '../cubit/donation_state.dart';
import '../widgets/donation_widgets.dart';

/// Donor info interface for reusability
class DonorInfo {
  final String name;
  final String phone;
  final String? email;
  final String donorType; // 'donor' or 'hospital'

  const DonorInfo({
    required this.name,
    required this.phone,
    this.email,
    this.donorType = 'donor',
  });
}

/// Reusable donation section that can be used by both Donor and Hospital
class DonationSectionWidget extends StatefulWidget {
  final String requestId;
  final String patientName;
  final String bloodGroup;
  final String hospitalName;
  final String? companionMobile;
  final DonorInfo donorInfo;
  final VoidCallback? onDonationComplete;

  const DonationSectionWidget({
    super.key,
    required this.requestId,
    required this.patientName,
    required this.bloodGroup,
    required this.hospitalName,
    this.companionMobile,
    required this.donorInfo,
    this.onDonationComplete,
  });

  @override
  State<DonationSectionWidget> createState() => _DonationSectionWidgetState();
}

class _DonationSectionWidgetState extends State<DonationSectionWidget> {
  Donation? _myDonation;
  bool _checkedForExistingDonation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForExistingDonation();
    });
  }

  void _checkForExistingDonation() {
    if (_checkedForExistingDonation) return;
    _checkedForExistingDonation = true;
    context.read<DonationCubit>().getMyDonations();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DonationCubit, DonationState>(
      listener: (context, state) {
        if (state is DonationOfferCreated) {
          setState(() {
          _myDonation = state.donation;
        });
          CustomSnackBar.showSuccess(context, AppStrings.donationOfferCreated);
        } else if (state is DonationsLoaded) {
          final myDonation = state.donations
              .where(
                (d) =>
                    d.requestId == widget.requestId &&
                    (d.status == DonationStatus.pending ||
                        d.status == DonationStatus.accepted),
              )
              .firstOrNull;

          if (myDonation != null) {
            setState(() {
              _myDonation = myDonation;
            });
          }
        } else if (state is OtpVerified) {
          CustomSnackBar.showSuccess(context, state.message);
          widget.onDonationComplete?.call();
        } else if (state is DonationError) {
          CustomSnackBar.showError(context, state.message);
        }
      },
      builder: (context, state) {
        if (state is DonationLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.red),
          );
        }

        // Show OTP section if donation exists
        if (_myDonation != null) {
          return DonationOfferSentWidget(
            onEnterOtp: () => _showOtpDialog(context, _myDonation!.id),
          );
        }

        // Show donate section
        return Column(
          children: [
            WantToHelpWidget(bloodGroup: widget.bloodGroup),
            const SizedBox(height: 16),
            DonateButton(
              onPressed: () => _showDonateDialog(context),
              isLoading: state is DonationLoading,
            ),
            if (widget.companionMobile != null) ...[
              const SizedBox(height: 12),
              CallHospitalButton(
                onPressed: () => _callHospital(widget.companionMobile!),
              ),
            ],
          ],
        );
      },
    );
  }

  void _showDonateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => DonationConfirmDialog(
        patientName: widget.patientName,
        bloodGroup: widget.bloodGroup,
        hospitalName: widget.hospitalName,
        initialName: widget.donorInfo.name,
        initialPhone: widget.donorInfo.phone,
        initialEmail: widget.donorInfo.email,
        onConfirm: (name, phone, email) {
          context.read<DonationCubit>().createDonationOffer(
            requestId: widget.requestId,
            donorName: name,
            donorPhone: phone,
            donorEmail: email,
          );
        },
      ),
    );
  }

  void _showOtpDialog(BuildContext context, String donationId) {
    showDialog(
      context: context,
      builder: (dialogContext) => OtpVerificationDialog(
        donationId: donationId,
        onVerify: (otp) {
          Navigator.pop(dialogContext);
          context.read<DonationCubit>().verifyOtp(
            donationId: donationId,
            otpCode: otp,
          );
        },
      ),
    );
  }

  void _callHospital(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

/// Creates a DonationCubit wrapped DonationSectionWidget
class DonationSection extends StatelessWidget {
  final String requestId;
  final String patientName;
  final String bloodGroup;
  final String hospitalName;
  final String? companionMobile;
  final DonorInfo donorInfo;
  final VoidCallback? onDonationComplete;

  const DonationSection({
    super.key,
    required this.requestId,
    required this.patientName,
    required this.bloodGroup,
    required this.hospitalName,
    this.companionMobile,
    required this.donorInfo,
    this.onDonationComplete,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DonationCubit>(),
      child: DonationSectionWidget(
        requestId: requestId,
        patientName: patientName,
        bloodGroup: bloodGroup,
        hospitalName: hospitalName,
        companionMobile: companionMobile,
        donorInfo: donorInfo,
        onDonationComplete: onDonationComplete,
      ),
    );
  }
}
