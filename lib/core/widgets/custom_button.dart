import 'package:blood_donation_app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double width;
  final Color backgroundColor;

  const CustomElevatedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.width = double.infinity,
    this.backgroundColor = AppColors.red,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      width: width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: onPressed != null ? backgroundColor : Colors.grey,
        ),
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}
