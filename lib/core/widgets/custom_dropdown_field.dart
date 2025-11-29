import 'package:blood_donation_app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class CustomDropdownField extends StatelessWidget {
  final String label;
  final String hint;
  final List<String> items;
  final String? value;
  final bool isDisabled;
  final String? Function(String?)? validator;
  final ValueChanged<String?>? onChanged;
  final VoidCallback? onTap; // Added for City dropdown logic

  const CustomDropdownField({
    super.key,
    required this.label,
    required this.hint,
    required this.items,
    this.value,
    this.isDisabled = false,
    this.validator,
    this.onChanged,
    this.onTap,
  });
  OutlineInputBorder _getBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: color,
        width: 2.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: isDisabled ? onTap : null, // Handle onTap for disabled state
          child: DropdownButtonFormField<String>(
            initialValue: value,
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: isDisabled ? null : onChanged,
            validator: (String? v) => validator != null ? validator!(v) : null,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color:  AppColors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
              ),
              border: _getBorder(AppColors.greyBorder),
              enabledBorder: _getBorder(AppColors.greyBorder),
              focusedBorder: _getBorder(AppColors.red),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            ),
            // The item builder ensures the overlay for the dropdown still works
            // when the main widget is wrapped in a GestureDetector.
            isExpanded: true,
            icon: Icon(Icons.keyboard_arrow_down, color: AppColors.greyBorder),
          ),
        ),
      ],
    );
  }
}