import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/blog_texts.dart';

class Blog1Screen extends StatelessWidget {
  const Blog1Screen({super.key});

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
                    image: const AssetImage('assets/benifits.png'),
                    height: 43,
                    width: 43,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    AppStrings.benefitsScreenTitle,
                    style: AppTextStyles.blogTitleTextStyle,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                AppStrings.benefitsSectionHeader,
                style: AppTextStyles.blogTextStyle,
              ),
              const SizedBox(height: 15),
              BlogTexts(
                title: AppStrings.benefit1Title,
                body: AppStrings.benefit1Body,
              ),
              BlogTexts(
                title: AppStrings.benefit2Title,
                body: AppStrings.benefit2Body,
              ),
              BlogTexts(
                title: AppStrings.benefit3Title,
                body: AppStrings.benefit3Body,
              ),
              BlogTexts(
                title: AppStrings.benefit4Title,
                body: AppStrings.benefit4Body,
              ),
              BlogTexts(
                title: AppStrings.benefit5Title,
                body: AppStrings.benefit5Body,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
