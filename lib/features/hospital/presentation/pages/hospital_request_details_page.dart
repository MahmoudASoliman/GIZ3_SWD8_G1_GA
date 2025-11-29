import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../donation/domain/entities/donation.dart';
import '../../../donation/presentation/cubit/donation_cubit.dart';
import '../../../donation/presentation/cubit/donation_state.dart';
import '../../../donation/presentation/widgets/donation_offer_card.dart';
import '../cubit/hospital_cubit.dart';
import '../cubit/hospital_state.dart';

/// Hospital request details page with donation offers
class HospitalRequestDetailsPage extends StatefulWidget {
  final String requestId;

  const HospitalRequestDetailsPage({super.key, required this.requestId});

  @override
  State<HospitalRequestDetailsPage> createState() =>
      _HospitalRequestDetailsPageState();
}

class _HospitalRequestDetailsPageState
    extends State<HospitalRequestDetailsPage> {
  Donation? _myDonation;
  bool _checkedForExistingDonation = false;

  /// Check if current user already has a donation for this request
  void _checkForExistingDonation(BuildContext context) {
    if (_checkedForExistingDonation) return;
    _checkedForExistingDonation = true;

    // Load my donations to check if I already donated
    context.read<DonationCubit>().getMyDonations();
  }

  @override
  void initState() {
    super.initState();

    // Load hospital profile if not loaded
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser != null) {
      final hospitalCubit = context.read<HospitalCubit>();
      if (hospitalCubit.profile == null) {
        hospitalCubit.loadProfile(currentUser.id);
      }
    }

    // Load request details
    context.read<HospitalCubit>().loadRequestDetails(widget.requestId);
    // Load donations for this request
    context.read<DonationCubit>().getDonationsForRequest(widget.requestId);
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
      body: BlocConsumer<HospitalCubit, HospitalState>(
        listener: (context, state) {
          if (state is HospitalRequestStatusUpdated) {
            CustomSnackBar.showSuccess(context, state.message);
            // Go back and refresh the list
            Navigator.pop(context, true);
          } else if (state is HospitalError) {
            CustomSnackBar.showError(context, state.message);
          }
        },
        builder: (context, state) {
          // Show loading for initial state or loading state
          if (state is HospitalLoading || state is HospitalInitial) {
            return const LoadingWidget(message: 'Loading details...');
          }

          // Show error only if it's an error state
          if (state is HospitalError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 80,
                    color: AppColors.lightGrey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to load request',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: const TextStyle(fontSize: 14, color: AppColors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<HospitalCubit>().loadRequestDetails(
                        widget.requestId,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.red,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Try to find the request in either state
          dynamic request;

          if (state is HospitalRequestsLoaded) {
            try {
              request = state.requests.firstWhere(
                (r) => r.id == widget.requestId,
              );
            } catch (_) {
              request = null;
            }
          } else if (state is HospitalAllPendingRequestsLoaded) {
            try {
              request = state.requests.firstWhere(
                (r) => r.id == widget.requestId,
              );
            } catch (_) {
              request = null;
            }
          } else if (state is HospitalRequestDetailsLoaded) {
            request = state.request;
          }

          // If request is still null (in transition states), show loading
          if (request == null) {
            return const LoadingWidget(message: 'Loading details...');
          }

          // Check if this is my request or someone else's
          final hospitalCubit = context.read<HospitalCubit>();
          final isMyRequest = request.hospitalId == hospitalCubit.profile?.id;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Blood Type Header
                Center(
                  child: Column(
                    children: [
                      Image.asset('assets/Drop.png', height: 60),
                      const SizedBox(height: 8),
                      Text(
                        'Request #${request.id.substring(0, 8)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.red,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildStatusChip(request.status.value),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Request Info Card
                _buildInfoCard([
                  _buildInfoRow(AppStrings.patientName, request.patientName),
                  _buildInfoRow(
                    AppStrings.bloodGroup,
                    request.bloodGroup,
                    isBloodGroup: true,
                  ),
                  _buildInfoRow(
                    AppStrings.roomNumber,
                    request.roomNumber ?? '-',
                  ),
                  _buildInfoRow(
                    AppStrings.companionNumber,
                    request.companionMobile,
                  ),
                  _buildInfoRow(AppStrings.governate, request.governate),
                  _buildInfoRow(AppStrings.city, request.city),
                  _buildInfoRow('Hospital', request.hospitalName),
                ]),
                const SizedBox(height: 24),

                // Show different actions based on ownership
                if (isMyRequest) ...[
                  // MY REQUEST: Show donation offers and cancel button
                  _buildDonationOffersSection(context),
                  const SizedBox(height: 24),

                  if (request.status.value == 'pending')
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showCancelDialog(context),
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        label: const Text(
                          'Cancel Request',
                          style: TextStyle(color: Colors.red),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                ] else ...[
                  // OTHER'S REQUEST: Show donate button or existing donation
                  if (request.status.value == 'pending')
                    _buildHospitalDonateSection(context, request),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHospitalDonateSection(BuildContext context, dynamic request) {
    return BlocConsumer<DonationCubit, DonationState>(
      listener: (context, donationState) {
        if (donationState is DonationOfferCreated) {
          setState(() {
            _myDonation = donationState.donation;
          });
          CustomSnackBar.showSuccess(context, 'Donation offer submitted!');
        } else if (donationState is DonationsLoaded) {
          // Check if hospital has existing donation for this request
          final myDonation = donationState.donations
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
        } else if (donationState is OtpVerified) {
          CustomSnackBar.showSuccess(context, donationState.message);
          Navigator.pop(context);
        } else if (donationState is DonationError) {
          CustomSnackBar.showError(context, donationState.message);
        }
      },
      builder: (context, donationState) {
        // Check for existing donation on first build
        if (!_checkedForExistingDonation) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _checkForExistingDonation(context);
          });
        }

        if (donationState is DonationLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.red),
          );
        }

        // Show existing donation status if hospital already donated
        if (_myDonation != null) {
          return Center(child: _buildMyDonationStatus(context, _myDonation!));
        }

        // Show donate button
        return _buildDonateSection(context, request);
      },
    );
  }

  Widget _buildMyDonationStatus(BuildContext context, Donation donation) {
    final statusColor = donation.status == DonationStatus.accepted
        ? Colors.green
        : Colors.orange;
    final statusText = donation.status == DonationStatus.accepted
        ? 'Accepted - Enter OTP to complete'
        : 'Pending - Waiting for approval';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(
            donation.status == DonationStatus.accepted
                ? Icons.check_circle
                : Icons.hourglass_empty,
            color: statusColor,
            size: 48,
          ),
          const SizedBox(height: 12),
          const Text(
            'Your Donation Offer',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),

          // Show OTP button only if accepted
          if (donation.status == DonationStatus.accepted) ...[
            const Text(
              'Get the OTP from the hospital to complete the donation.',
              style: TextStyle(fontSize: 14, color: AppColors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showOtpInputDialog(context, donation.id),
                icon: const Icon(Icons.lock_open),
                label: const Text('Enter OTP'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ] else ...[
            const Text(
              'The hospital will review your offer.',
              style: TextStyle(fontSize: 14, color: AppColors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  void _showOtpInputDialog(BuildContext context, String donationId) {
    final otpController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.lock, color: AppColors.red),
            SizedBox(width: 8),
            Text('Enter OTP'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the 6-digit OTP provided by the hospital.'),
            const SizedBox(height: 16),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
              ),
              decoration: InputDecoration(
                hintText: '000000',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (otpController.text.length == 6) {
                Navigator.pop(dialogContext);
                context.read<DonationCubit>().verifyOtp(
                  donationId: donationId,
                  otpCode: otpController.text,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  Widget _buildDonateSection(BuildContext context, dynamic request) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.lightRed.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.volunteer_activism,
                size: 48,
                color: AppColors.red,
              ),
              const SizedBox(height: 12),
              const Text(
                'Want to help?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'This patient needs ${request.bloodGroup} blood type',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.grey),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showDonateDialog(context, request),
            icon: const Icon(Icons.favorite, color: Colors.white),
            label: const Text(
              'Donate Blood',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Call hospital button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _callHospital(request.companionMobile),
            icon: const Icon(Icons.phone, color: AppColors.red),
            label: const Text(
              'Call Hospital',
              style: TextStyle(color: AppColors.red),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.red),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  void _showDonateDialog(BuildContext context, dynamic request) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.volunteer_activism, color: AppColors.red),
            SizedBox(width: 8),
            Text('Confirm Donation'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You are about to donate blood for:'),
            const SizedBox(height: 12),
            Text(
              'Patient: ${request.patientName}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Blood Group: ${request.bloodGroup}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Hospital: ${request.hospitalName}'),
            const SizedBox(height: 12),
            const Text(
              'The hospital will be notified of your offer.',
              style: TextStyle(color: AppColors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _submitDonation(context, request);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _submitDonation(BuildContext context, dynamic request) {
    final hospitalCubit = context.read<HospitalCubit>();
    final profile = hospitalCubit.profile;

    if (profile == null) {
      CustomSnackBar.showError(context, 'Error: Hospital profile not loaded');
      return;
    }

    // Create donation using DonationCubit
    context.read<DonationCubit>().createDonationOffer(
      requestId: request.id,
      donorName: profile.name,
      donorPhone: profile.mobile,
      donorEmail: null,
    );

    CustomSnackBar.showSuccess(
      context,
      'Donation offer submitted! The hospital will be notified.',
    );
    Navigator.pop(context);
  }

  Future<void> _callHospital(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;
    switch (status) {
      case 'completed':
        color = Colors.green;
        text = AppStrings.statusCompleted;
        break;
      case 'cancelled':
        color = Colors.grey;
        text = AppStrings.statusCancelled;
        break;
      case 'accepted':
        color = Colors.blue;
        text = AppStrings.statusAccepted;
        break;
      default:
        color = Colors.orange;
        text = AppStrings.statusPending;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isBloodGroup = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.grey,
                fontSize: 14,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: isBloodGroup ? 16 : 14,
                fontFamily: 'Poppins',
                color: isBloodGroup ? AppColors.red : AppColors.black,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationOffersSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.volunteer_activism, color: AppColors.red),
            const SizedBox(width: 8),
            Text(
              AppStrings.donationOffers,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {
                context.read<DonationCubit>().getDonationsForRequest(
                  widget.requestId,
                );
              },
              icon: const Icon(Icons.refresh, color: AppColors.red),
            ),
          ],
        ),
        const SizedBox(height: 12),
        BlocConsumer<DonationCubit, DonationState>(
          listener: (context, state) {
            if (state is DonationUpdated) {
              CustomSnackBar.showSuccess(context, state.message);
              context.read<DonationCubit>().getDonationsForRequest(
                widget.requestId,
              );
            } else if (state is DonationError) {
              CustomSnackBar.showError(context, state.message);
            }
          },
          builder: (context, state) {
            // Show loading for initial state or loading state
            if (state is DonationLoading || state is DonationInitial) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(color: AppColors.red),
                ),
              );
            }

            if (state is DonationsLoaded) {
              if (state.donations.isEmpty) {
                return _buildEmptyDonations();
              }

              return Column(
                children: state.donations.map((donation) {
                  return DonationOfferCard(
                    donation: donation,
                    showActions: donation.status == DonationStatus.pending,
                    onReject: () => _showDeclineDialog(context, donation),
                    onCall: () => _callDonor(donation.donorPhone),
                  );
                }).toList(),
              );
            }

            return _buildEmptyDonations();
          },
        ),
      ],
    );
  }

  Widget _buildEmptyDonations() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.lightRed.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.volunteer_activism_outlined,
            size: 64,
            color: AppColors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.noDonationOffers,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.grey,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  void _showDeclineDialog(BuildContext context, Donation donation) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.cancel, color: Colors.red),
            SizedBox(width: 8),
            Text('Decline Donation'),
          ],
        ),
        content: Text(
          'Decline donation offer from ${donation.donorName}?\n\n'
          'They will be able to offer again if the request is still open.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<DonationCubit>().rejectDonation(donation.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Decline'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Request'),
        content: const Text(
          'Are you sure you want to cancel this blood request?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<HospitalCubit>().updateRequestStatus(
                requestId: widget.requestId,
                status: RequestStatus.cancelled,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _callDonor(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
