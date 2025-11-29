import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../cubit/hospital_cubit.dart';
import '../cubit/hospital_state.dart';
import 'create_request_page.dart';
import 'hospital_donation_page.dart';

/// Hospital requests page - shows hospital's requests and all pending requests
class HospitalRequestsPage extends StatefulWidget {
  final int initialTabIndex;

  const HospitalRequestsPage({super.key, this.initialTabIndex = 0});

  @override
  State<HospitalRequestsPage> createState() => _HospitalRequestsPageState();
}

class _HospitalRequestsPageState extends State<HospitalRequestsPage>
    with SingleTickerProviderStateMixin {
  bool _isFirstLoad = true;
  late TabController _tabController;
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTabIndex;
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _tabController.addListener(_onTabChanged);
  }

  @override
  void didUpdateWidget(HospitalRequestsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update tab when initialTabIndex changes
    if (widget.initialTabIndex != oldWidget.initialTabIndex) {
      _tabController.animateTo(widget.initialTabIndex);
      setState(() => _currentTab = widget.initialTabIndex);
      _loadDataForCurrentTab();
    }
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final newTab = _tabController.index;
    if (newTab != _currentTab) {
      setState(() => _currentTab = newTab);
      _loadDataForCurrentTab();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isFirstLoad) {
      _isFirstLoad = false;
      _loadProfileAndRequests();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadProfileAndRequests() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<HospitalCubit>().loadProfile(authState.user.id);
    }
  }

  void _loadDataForCurrentTab() {
    final hospitalCubit = context.read<HospitalCubit>();
    if (hospitalCubit.profile != null) {
      if (_currentTab == 0) {
        hospitalCubit.loadRequests(hospitalCubit.profile!.id);
      } else {
        hospitalCubit.loadAllPendingRequests(hospitalCubit.profile!.governate);
      }
    }
  }

  void _loadRequests() {
    final hospitalCubit = context.read<HospitalCubit>();
    if (hospitalCubit.profile != null) {
      if (_currentTab == 0) {
        hospitalCubit.loadRequests(hospitalCubit.profile!.id);
      } else {
        hospitalCubit.loadAllPendingRequests(hospitalCubit.profile!.governate);
      }
    } else {
      _loadProfileAndRequests();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocConsumer<HospitalCubit, HospitalState>(
        listener: (context, state) {
          if (state is HospitalProfileLoaded) {
            // Profile loaded, load requests based on current tab
            _loadDataForCurrentTab();
          } else if (state is HospitalRequestCreated) {
            CustomSnackBar.showSuccess(context, state.message);
            _loadRequests();
          } else if (state is HospitalRequestDeleted) {
            CustomSnackBar.showSuccess(context, state.message);
            _loadRequests();
          } else if (state is HospitalError) {
            CustomSnackBar.showError(context, state.message);
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              _buildHeader(context),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMyRequestsTab(context, state),
                    _buildAllRequestsTab(context, state),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
      decoration: const BoxDecoration(color: AppColors.lightRed),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Blood Requests',
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
                child: Image.asset('assets/refresh.png'),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final hospitalCubit = context.read<HospitalCubit>();
              final authCubit = context.read<AuthCubit>();
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MultiBlocProvider(
                    providers: [
                      BlocProvider.value(value: hospitalCubit),
                      BlocProvider.value(value: authCubit),
                    ],
                    child: const CreateRequestPage(),
                  ),
                ),
              );
              if (result == true) {
                _loadRequests();
              }
            },
            child: const Text(
              "Add New Request",
              style: TextStyle(
                color: AppColors.white,
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.lightRed,
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.red,
        indicatorWeight: 3,
        labelColor: AppColors.red,
        unselectedLabelColor: AppColors.grey,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        tabs: const [
          Tab(text: 'My Requests'),
          Tab(text: 'Other Requests'),
        ],
      ),
    );
  }

  // ==================== MY REQUESTS TAB ====================
  Widget _buildMyRequestsTab(BuildContext context, HospitalState state) {
    if (state is HospitalLoading && _currentTab == 0) {
      return const Center(
        child: LoadingWidget(message: 'Loading your requests...'),
      );
    }

    if (state is HospitalError && _currentTab == 0) {
      return Center(
        child: ErrorDisplayWidget(
          message: state.message,
          onRetry: _loadRequests,
        ),
      );
    }

    if (state is HospitalRequestsLoaded) {
      if (state.requests.isEmpty) {
        return const Center(
          child: EmptyStateWidget(
            message:
                'No blood requests yet\nTap "Add New Request" to create one',
            icon: Icons.bloodtype_outlined,
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: state.requests.length,
        itemBuilder: (context, index) {
          final request = state.requests[index];
          return _buildMyRequestCard(
            context,
            requestNumber: 'Request #${state.requests.length - index}',
            roomNumber: request.roomNumber ?? 'N/A',
            patientName: request.patientName,
            bloodGroup: request.bloodGroup,
            requestId: request.id,
            status: request.status.value,
          );
        },
      );
    }

    return const Center(child: Text('Pull down to load requests'));
  }

  // ==================== ALL REQUESTS TAB ====================
  Widget _buildAllRequestsTab(BuildContext context, HospitalState state) {
    if (state is HospitalLoading && _currentTab == 1) {
      return const Center(
        child: LoadingWidget(message: 'Loading all requests...'),
      );
    }

    if (state is HospitalError && _currentTab == 1) {
      return Center(
        child: ErrorDisplayWidget(
          message: state.message,
          onRetry: _loadRequests,
        ),
      );
    }

    if (state is HospitalAllPendingRequestsLoaded) {
      final hospitalCubit = context.read<HospitalCubit>();
      final myHospitalId = hospitalCubit.profile?.id;

      // Filter to show only OTHER hospitals' requests (exclude own)
      final otherRequests = state.requests
          .where((r) => r.hospitalId != myHospitalId)
          .toList();

      if (otherRequests.isEmpty) {
        return const Center(
          child: EmptyStateWidget(
            message: 'No blood requests available\nCheck back later!',
            icon: Icons.search_off,
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: otherRequests.length,
        itemBuilder: (context, index) {
          final request = otherRequests[index];
          return _buildDonationRequestCard(context, request);
        },
      );
    }

    return const Center(child: Text('Tap to load requests'));
  }

  Widget _buildMyRequestCard(
    BuildContext context, {
    required String requestNumber,
    required String roomNumber,
    required String patientName,
    required String bloodGroup,
    required String requestId,
    required String status,
  }) {
    return InkWell(
      onTap: () {
        context
            .push('/hospital-request-details/$requestId')
            .then((_) => _loadRequests()); // Refresh after returning
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.lightGrey, width: 1.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        requestNumber,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusBadge(status),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text("Room No.: $roomNumber", style: _subTextStyle()),
                  Text("Patient Name: $patientName", style: _subTextStyle()),
                  Text("Blood Group: $bloodGroup", style: _subTextStyle()),
                ],
              ),
            ),
            InkWell(
              onTap: () => _showDeleteConfirmation(context, requestId),
              child: Image.asset('assets/delete.png'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationRequestCard(BuildContext context, dynamic request) {
    // Save cubits before navigation to avoid deactivated widget error
    final hospitalCubit = context.read<HospitalCubit>();
    final authCubit = context.read<AuthCubit>();

    return InkWell(
      onTap: () {
        // Navigate to donation page for hospitals to donate
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider.value(value: hospitalCubit),
                BlocProvider.value(value: authCubit),
              ],
              child: HospitalDonationPage(request: request),
            ),
          ),
        ).then((_) => _loadRequests()); // Refresh after returning
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.lightGrey, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.lightRed,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.bloodtype,
                color: AppColors.red,
                size: 32,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.hospitalName ?? 'Hospital',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Blood Group: ${request.bloodGroup}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Inter',
                      color: AppColors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${request.governate} - ${request.city}',
                    style: _subTextStyle(),
                  ),
                  Text(
                    'Patient: ${request.patientName}',
                    style: _subTextStyle(),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.grey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'pending':
        bgColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        break;
      case 'accepted':
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        break;
      case 'completed':
        bgColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        break;
      default:
        bgColor = Colors.grey.shade100;
        textColor = Colors.grey.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String requestId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Request'),
        content: const Text('Are you sure you want to delete this request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<HospitalCubit>().deleteRequest(requestId);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  TextStyle _subTextStyle() {
    return const TextStyle(
      fontSize: 14,
      color: AppColors.grey,
      fontFamily: 'Inter',
    );
  }
}
