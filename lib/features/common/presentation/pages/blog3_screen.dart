import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/blog_texts.dart';

class Blog3Screen extends StatelessWidget {
  const Blog3Screen({super.key});

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
                    image: const AssetImage('assets/recovery.png'),
                    height: 44,
                    width: 44,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    AppStrings.recoveryScreenTitle,
                    style: AppTextStyles.blogTitleTextStyle,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                AppStrings.immediateRecoveryHeader,
                style: AppTextStyles.blogTextStyle,
              ),
              const SizedBox(height: 15),
              BlogTexts(
                title: AppStrings.immediate1Title,
                body: AppStrings.immediate1Body,
              ),
              BlogTexts(
                title: AppStrings.immediate2Title,
                body: AppStrings.immediate2Body,
              ),
              BlogTexts(
                title: AppStrings.immediate3Title,
                body: AppStrings.immediate3Body,
              ),
              BlogTexts(
                title: AppStrings.immediate4Title,
                body: AppStrings.immediate4Body,
              ),
              BlogTexts(
                title: AppStrings.immediate5Title,
                body: AppStrings.immediate5Body,
              ),
              const SizedBox(height: 10),
              Text(
                AppStrings.longTermRecoveryHeader,
                style: AppTextStyles.blogTextStyle,
              ),
              const SizedBox(height: 15),
              BlogTexts(
                title: AppStrings.longTerm1Title,
                body: AppStrings.longTerm1Body,
              ),
              BlogTexts(
                title: AppStrings.longTerm2Title,
                body: AppStrings.longTerm2Body,
              ),
              BlogTexts(
                title: AppStrings.longTerm3Title,
                body: AppStrings.longTerm3Body,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
