import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../cubit/donor_cubit.dart';
import '../cubit/donor_state.dart';
import 'request_details_page.dart';

/// Donor requests page - Original UI with backend integration
class DonorRequestsPage extends StatefulWidget {
  const DonorRequestsPage({super.key});

  @override
  State<DonorRequestsPage> createState() => _DonorRequestsPageState();
}

class _DonorRequestsPageState extends State<DonorRequestsPage>
    with WidgetsBindingObserver {
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadRequests();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isFirstLoad) {
      _isFirstLoad = false;
      _loadRequests();
    }
  }

  void _loadRequests() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<DonorCubit>().loadProfile(authState.user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 20),
            _buildRequestsSection(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------
  // HEADER
  // ------------------------------------------------------
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
      decoration: const BoxDecoration(color: AppColors.lightRed),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Donation Requests',
                style: TextStyle(
                  color: AppColors.red,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: _loadRequests,
                child: Image.asset('assets/refresh.png', height: 31, width: 31),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Share your Blood\nSave Life',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
              color: AppColors.black,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------
  // REQUEST LIST SECTION
  // ------------------------------------------------------
  Widget _buildRequestsSection(BuildContext context) {
    return BlocConsumer<DonorCubit, DonorState>(
      listener: (context, state) {
        if (state is DonorProfileLoaded) {
          context.read<DonorCubit>().loadRequests(
            bloodGroup: state.profile.bloodGroup,
            governate: state.profile.governate,
          );
        } else if (state is DonorRequestAccepted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
          _loadRequests();
        } else if (state is DonorError) {
          // Don't show error for profile not found
          if (!state.message.contains('0 rows') &&
              !state.message.contains('single JSON object')) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        }
      },
      builder: (context, state) {
        if (state is DonorLoading) {
          return const Padding(
            padding: EdgeInsets.all(50),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.red),
            ),
          );
        }

        if (state is DonorError) {
          if (state.message.contains('0 rows') ||
              state.message.contains('single JSON object')) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.person_add,
                      size: 64,
                      color: AppColors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Please complete your profile first',
                      style: TextStyle(fontSize: 16, color: AppColors.grey),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Go to Profile tab to set up your donor profile',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.grey),
                    ),
                  ],
                ),
              ),
            );
          }
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadRequests,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is DonorRequestsLoaded) {
          if (state.requests.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(50),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.bloodtype_outlined,
                      size: 64,
                      color: AppColors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No blood requests available',
                      style: TextStyle(fontSize: 16, color: AppColors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: state.requests.map((request) {
                return _buildRequestItem(context: context, request: request);
              }).toList(),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  // ------------------------------------------------------
  // REQUEST CARD
  // ------------------------------------------------------
  Widget _buildRequestItem({
    required BuildContext context,
    required dynamic request,
  }) {
    final isCompleted = request.status.value == 'completed';

    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider.value(value: context.read<DonorCubit>()),
                BlocProvider.value(value: context.read<AuthCubit>()),
              ],
              child: RequestDetailsPage(requestId: request.id),
            ),
          ),
        );
        // Refresh when returning from details page
        _loadRequests();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isCompleted
              ? Colors.green.withValues(alpha: 0.05)
              : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isCompleted
                ? Colors.green.withValues(alpha: 0.3)
                : AppColors.lightGrey,
            width: 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                Image.asset('assets/Drop.png', height: 64, width: 64),
                if (isCompleted)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${request.bloodGroup} ',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Inter',
                                  color: AppColors.red,
                                ),
                              ),
                              TextSpan(
                                text: '- ${request.hospitalName}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Inter',
                                  color: AppColors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (isCompleted)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Completed',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 16,
                        color: AppColors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Patient: ${request.patientName}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'Inter',
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppColors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${request.governate} - ${request.city}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'Inter',
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                  if (request.roomNumber != null &&
                      request.roomNumber.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.meeting_room_outlined,
                          size: 16,
                          color: AppColors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Room: ${request.roomNumber}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'Inter',
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
