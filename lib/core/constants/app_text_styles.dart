import 'package:flutter/material.dart';
import 'package:blood_donation_app/core/constants/app_colors.dart';

class AppTextStyles {
  static const TextStyle infoTextStyle = TextStyle(
    color: AppColors.black,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    fontFamily: 'Poppins',
  );

  static const TextStyle buttonTextStyle = TextStyle(
    color: AppColors.white,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    fontFamily: 'Inter',
  );

    static const TextStyle blogTitleTextStyle = TextStyle(
    color: AppColors.red,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins',
  );

    static const TextStyle blogTextStyle = TextStyle(
    color: AppColors.black,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins',
  );
}