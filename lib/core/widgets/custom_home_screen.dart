import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import 'custom_button.dart';

/// User type enum for home screen
enum UserType { donor, hospital }

/// Custom Home Screen - Shared between Donor and Hospital
class CustomHomeScreen extends StatelessWidget {
  final String userName;
  final UserType userType;
  final int unreadNotificationsCount;
  final VoidCallback? onPrimaryButtonPressed;
  final VoidCallback? onSecondaryButtonPressed;
  final VoidCallback? onNotificationPressed;

  const CustomHomeScreen({
    super.key,
    required this.userName,
    required this.userType,
    this.unreadNotificationsCount = 0,
    this.onPrimaryButtonPressed,
    this.onSecondaryButtonPressed,
    this.onNotificationPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(context),
          const SizedBox(height: 20),
          _buildBanner(context),
          const SizedBox(height: 10),
          _buildBlogsSection(context),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Header with logo, username and notification
  Widget _buildHeader(BuildContext context) {
    // Get the top padding (status bar height)
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(20, topPadding + 16, 20, 24),
      width: double.infinity,
      decoration: const BoxDecoration(color: AppColors.lightRed),
      child: Row(
        children: [
          // Logo
          Image.asset('assets/reversed_logo.png', height: 75),
          const SizedBox(width: 12),
          // User Name
          Text(
            userName,
            style: const TextStyle(
              color: AppColors.red,
              fontSize: 26,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
          const Spacer(),
          // Notification Icon with Badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none_outlined,
                  color: AppColors.grey,
                  size: 32,
                ),
                onPressed:
                    onNotificationPressed ??
                    () {
                      context.push('/notifications');
                    },
              ),
              if (unreadNotificationsCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      unreadNotificationsCount > 99
                          ? '99+'
                          : unreadNotificationsCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Banner with image and action buttons
  Widget _buildBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(color: Colors.white),
        child: Column(
          children: [
            Row(
              children: [
                Image.asset('assets/donation.png', height: 139, width: 200),
                const Expanded(
                  child: Text(
                    'Save a life\nGive Blood',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                      color: AppColors.black,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Action buttons row - responsive
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // Primary button (Make a Request for Hospital, Donate NOW for Donor)
                  Expanded(
                    child: CustomElevatedButton(
                      onPressed: onPrimaryButtonPressed ?? () {},
                      child: Text(
                        userType == UserType.hospital
                            ? 'Make a\nRequest'
                            : 'Donate NOW',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.buttonTextStyle,
                      ),
                    ),
                  ),
                  // Secondary button (Donate NOW for Hospital only)
                  if (userType == UserType.hospital) ...[
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomElevatedButton(
                        onPressed: onSecondaryButtonPressed ?? () {},
                        child: const Text(
                          'Donate\nNOW',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.buttonTextStyle,
                        ),
                      ),
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

  /// Blogs section
  Widget _buildBlogsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Blogs',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 15),
          _buildBlogItem(
            context: context,
            iconPath: 'assets/benifits.png',
            title: 'Benefits of Blood Donation',
            onTap: () => context.push('/blog1'),
          ),
          _buildBlogItem(
            context: context,
            iconPath: 'assets/conditions.png',
            title: 'Conditions of Blood Donation',
            onTap: () => context.push('/blog2'),
          ),
          _buildBlogItem(
            context: context,
            iconPath: 'assets/recovery.png',
            title: 'Recovery After Donation',
            onTap: () => context.push('/blog3'),
          ),
        ],
      ),
    );
  }

  /// Blog item widget
  Widget _buildBlogItem({
    required BuildContext context,
    required String iconPath,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.lightGrey),
        ),
        child: Row(
          children: [
            Image.asset(iconPath, height: 64, width: 64),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                  color: AppColors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
