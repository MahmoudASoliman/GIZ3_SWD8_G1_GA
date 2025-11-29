import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/donation.dart';

/// Widget to display a donation offer card with OTP and countdown
class DonationOfferCard extends StatefulWidget {
  final Donation donation;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onCall;
  final bool showActions;

  const DonationOfferCard({
    super.key,
    required this.donation,
    this.onAccept,
    this.onReject,
    this.onCall,
    this.showActions = true,
  });

  @override
  State<DonationOfferCard> createState() => _DonationOfferCardState();
}

class _DonationOfferCardState extends State<DonationOfferCard> {
  Timer? _timer;
  Duration _remainingTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateRemainingTime();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateRemainingTime() {
    final remaining = widget.donation.otpExpiresAt.difference(DateTime.now());
    setState(() {
      _remainingTime = remaining.isNegative ? Duration.zero : remaining;
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemainingTime();
    });
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(DonationStatus status) {
    switch (status) {
      case DonationStatus.pending:
        return Colors.orange;
      case DonationStatus.accepted:
        return Colors.green;
      case DonationStatus.rejected:
        return Colors.red;
      case DonationStatus.completed:
        return Colors.blue;
      case DonationStatus.expired:
        return Colors.grey;
    }
  }

  String _getStatusText(DonationStatus status) {
    switch (status) {
      case DonationStatus.pending:
        return AppStrings.statusPending;
      case DonationStatus.accepted:
        return AppStrings.statusAccepted;
      case DonationStatus.rejected:
        return AppStrings.statusRejected;
      case DonationStatus.completed:
        return AppStrings.statusCompleted;
      case DonationStatus.expired:
        return AppStrings.statusExpired;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isExpired = _remainingTime == Duration.zero;
    final isPending = widget.donation.status == DonationStatus.pending;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status
          Row(
            children: [
              Icon(
                widget.donation.donorType == 'hospital'
                    ? Icons.local_hospital
                    : Icons.person,
                color: AppColors.red,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.donation.donorName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(
                    widget.donation.status,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusText(widget.donation.status),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(widget.donation.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Contact info
          Row(
            children: [
              const Icon(Icons.phone, size: 16, color: AppColors.grey),
              const SizedBox(width: 8),
              Text(
                widget.donation.donorPhone,
                style: const TextStyle(fontSize: 14, color: AppColors.grey),
              ),
              const Spacer(),
              if (widget.onCall != null)
                IconButton(
                  onPressed: widget.onCall,
                  icon: const Icon(Icons.call, color: Colors.green),
                  tooltip: AppStrings.contactDonor,
                ),
            ],
          ),

          if (widget.donation.donorEmail != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.email, size: 16, color: AppColors.grey),
                const SizedBox(width: 8),
                Text(
                  widget.donation.donorEmail!,
                  style: const TextStyle(fontSize: 14, color: AppColors.grey),
                ),
              ],
            ),
          ],

          const Divider(height: 24),

          // OTP and Timer
          if (isPending && !isExpired) ...[
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.otpCode,
                        style: TextStyle(fontSize: 12, color: AppColors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.donation.otpCode,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          color: AppColors.red,
                          letterSpacing: 4,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      AppStrings.expiresIn,
                      style: TextStyle(fontSize: 12, color: AppColors.grey),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _remainingTime.inHours < 1
                            ? Colors.red.withValues(alpha: 0.1)
                            : Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.timer,
                            size: 16,
                            color: _remainingTime.inHours < 1
                                ? Colors.red
                                : Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDuration(_remainingTime),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                              color: _remainingTime.inHours < 1
                                  ? Colors.red
                                  : Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ] else if (isExpired && isPending) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.timer_off, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(
                    AppStrings.otpExpired,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Action buttons - Only Decline, no Accept needed
          // Hospital gives OTP to donor verbally, donor enters it to complete
          if (widget.showActions && isPending && !isExpired) ...[
            const SizedBox(height: 12),
            // Instruction text
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Share this OTP with the donor to complete the donation',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Only Decline button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: widget.onReject,
                icon: const Icon(Icons.close, color: Colors.red),
                label: Text(
                  'Decline Donation',
                  style: const TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
