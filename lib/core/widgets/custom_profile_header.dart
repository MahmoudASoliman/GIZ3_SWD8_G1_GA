import 'package:blood_donation_app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final Widget imageWidget;
  final String labelText;
  final Color backgroundColor;
  final Color textColor;
  
  const ProfileHeader({
    super.key,
    required this.imageWidget,
    required this.labelText,
    required this.backgroundColor,
    this.textColor = AppColors.red,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            height: 78,
            width: 78,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: backgroundColor, 
            ),
            child: Center(child: imageWidget), 
          ),
          Text(
            labelText, 
            style: TextStyle(
              color:textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}