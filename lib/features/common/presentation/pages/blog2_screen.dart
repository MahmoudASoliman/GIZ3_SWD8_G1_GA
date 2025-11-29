import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/blog_texts.dart';

class Blog2Screen extends StatelessWidget {
  const Blog2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.grey),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Image(
            image: const AssetImage('assets/logo.png'),
            height: 73,
            width: 99,
          ),
        ],
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image(
                    image: const AssetImage('assets/conditions.png'),
                    height: 44,
                    width: 44,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    AppStrings.conditionsScreenTitle,
                    style: AppTextStyles.blogTitleTextStyle,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                AppStrings.generalConditionsHeader,
                style: AppTextStyles.blogTextStyle,
              ),
              const SizedBox(height: 15),
              BlogTexts(
                title: AppStrings.generalCondition1Title,
                body: AppStrings.generalCondition1Body,
              ),
              BlogTexts(
                title: AppStrings.generalCondition2Title,
                body: AppStrings.generalCondition2Body,
              ),
              BlogTexts(
                title: AppStrings.generalCondition3Title,
                body: AppStrings.generalCondition3Body,
              ),
              const SizedBox(height: 10),
              Text(
                AppStrings.temporaryDeferralHeader,
                style: AppTextStyles.blogTextStyle,
              ),
              const SizedBox(height: 10),
              Text(
                AppStrings.deferralIntroText,
                style: AppTextStyles.blogTextStyle,
              ),
              const SizedBox(height: 15),
              BlogTexts(
                title: AppStrings.deferralCondition1Title,
                body: AppStrings.deferralCondition1Body,
              ),
              BlogTexts(
                title: AppStrings.deferralCondition2Title,
                body: AppStrings.deferralCondition2Body,
              ),
              BlogTexts(
                title: AppStrings.deferralCondition3Title,
                body: AppStrings.deferralCondition3Body,
              ),
              BlogTexts(
                title: AppStrings.deferralCondition4Title,
                body: AppStrings.deferralCondition4Body,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
