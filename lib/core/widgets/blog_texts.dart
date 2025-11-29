import 'package:blood_donation_app/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

class BlogTexts extends StatelessWidget {
  final String title;
  final String body;

  const BlogTexts({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0), 
      child: RichText( 
        text: TextSpan(
          style: AppTextStyles.blogTextStyle,
          children: <TextSpan>[
            TextSpan(
              text: '• $title', 
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: ' $body'),
          ],
        ),
      ),
    );
  }
}