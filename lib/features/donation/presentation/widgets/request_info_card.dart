import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Reusable request info card widget
/// Shows request details in a card format
class RequestInfoCard extends StatelessWidget {
  final String requestId;
  final String patientName;
  final String bloodGroup;
  final String? roomNumber;
  final String companionMobile;
  final String hospitalName;
  final String governate;
  final String city;
  final String status;

  const RequestInfoCard({
    super.key,
    required this.requestId,
    required this.patientName,
    required this.bloodGroup,
    this.roomNumber,
    required this.companionMobile,
    required this.hospitalName,
    required this.governate,
    required this.city,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with blood drop and request ID
        Center(
          child: Column(
            children: [
              Image.asset('assets/Drop.png', height: 60),
              const SizedBox(height: 8),
              Text(
                'Request #${requestId.length > 8 ? requestId.substring(0, 8) : requestId}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.red,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 8),
              _buildStatusChip(status),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Info Card
        Container(
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
          child: Column(
            children: [
              _buildInfoRow('Patient Name', patientName),
              _buildInfoRow('Blood Group', bloodGroup, isBloodGroup: true),
              _buildInfoRow('Room Number', roomNumber ?? '-'),
              _buildInfoRow('Companion Number', companionMobile),
              _buildInfoRow('Hospital Name', hospitalName),
              _buildInfoRow('Governate', governate),
              _buildInfoRow('City', city),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;
    switch (status.toLowerCase()) {
      case 'completed':
        color = Colors.green;
        text = 'Completed';
        break;
      case 'cancelled':
        color = Colors.grey;
        text = 'Cancelled';
        break;
      case 'accepted':
        color = Colors.blue;
        text = 'Accepted';
        break;
      default:
        color = Colors.orange;
        text = 'Pending';
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
}

/// Completed request section
class RequestCompletedWidget extends StatelessWidget {
  const RequestCompletedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 72),
          const SizedBox(height: 16),
          const Text(
            'This request has been completed!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green,
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Thank you for your contribution to saving lives.',
            style: TextStyle(fontSize: 15, color: AppColors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Want to help section
class WantToHelpWidget extends StatelessWidget {
  final String bloodGroup;

  const WantToHelpWidget({super.key, required this.bloodGroup});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightRed.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Image.asset('assets/Drop.png', height: 40),
          const SizedBox(height: 8),
          const Text(
            'Want to help?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'This patient needs $bloodGroup blood type',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
