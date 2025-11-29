import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_dropdown_field.dart';
import '../../../../core/widgets/custom_profile_header.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../models/location_data.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../cubit/hospital_cubit.dart';
import '../cubit/hospital_state.dart';

/// Hospital Profile Setup Page with original UI design
class HospitalProfileSetupPage extends StatefulWidget {
  const HospitalProfileSetupPage({super.key});

  @override
  State<HospitalProfileSetupPage> createState() =>
      _HospitalProfileSetupPageState();
}

class _HospitalProfileSetupPageState extends State<HospitalProfileSetupPage> {
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;

  final TextEditingController _hospitalNameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _locationLinkController = TextEditingController();

  String? selectedGovernate;
  String? selectedCity;
  String? _governateError;
  String? _cityError;

  late final List<String> governates = LocationData.governateCityMap.keys
      .toList();

  @override
  void dispose() {
    _hospitalNameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _locationLinkController.dispose();
    super.dispose();
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    CustomSnackBar.showError(context, message);
  }

  void _showSuccessSnackbar(BuildContext context, String message) {
    CustomSnackBar.showSuccess(context, message);
  }

  bool _validateDropdowns() {
    bool isValid = true;

    if (selectedGovernate == null || selectedGovernate!.isEmpty) {
      _governateError = 'Please select a governate';
      isValid = false;
    } else {
      _governateError = null;
    }

    if (selectedCity == null || selectedCity!.isEmpty) {
      _cityError = 'Please select a city';
      isValid = false;
    } else {
      _cityError = null;
    }

    return isValid;
  }

  void _submitForm() {
    setState(() {
      _autoValidate = true;
    });

    final isFormValid = _formKey.currentState?.validate() ?? false;
    final isDropdownsValid = _validateDropdowns();

    setState(() {}); // Refresh to show dropdown errors

    if (isFormValid && isDropdownsValid) {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthAuthenticated) {
        context.read<HospitalCubit>().createProfile(
          userId: authState.user.id,
          name: _hospitalNameController.text.trim(),
          mobile: _mobileController.text.trim(),
          governate: selectedGovernate!,
          city: selectedCity!,
          address: _locationLinkController.text.trim().isNotEmpty
              ? _locationLinkController.text.trim()
              : _emailController.text.trim(),
        );
      }
    }
  }

  void _handleCityDropdownTap() {
    if (selectedGovernate == null) {
      _showErrorSnackbar(context, 'Please select a governate first.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> availableCities = selectedGovernate != null
        ? LocationData.governateCityMap[selectedGovernate] ?? []
        : [];

    final bool isCityDropdownDisabled = selectedGovernate == null;

    return BlocListener<HospitalCubit, HospitalState>(
      listener: (context, state) {
        if (state is HospitalProfileCreated) {
          _showSuccessSnackbar(context, 'Profile created successfully!');
        } else if (state is HospitalError) {
          _showErrorSnackbar(context, _parseErrorMessage(state.message));
        }
      },
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Form(
            key: _formKey,
            autovalidateMode: _autoValidate
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'Profile Setup',
                    style: TextStyle(
                      color: AppColors.red,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 16),
                  ProfileHeader(
                    imageWidget: const Image(image: AssetImage('assets/H.png')),
                    labelText: 'Hospital',
                    backgroundColor: AppColors.lightRed,
                  ),
                  const SizedBox(height: 33),

                  // Hospital Name Field
                  CustomTextField(
                    label: 'Hospital Name *',
                    hint: 'Enter hospital name',
                    keyboardType: TextInputType.name,
                    controller: _hospitalNameController,
                    validator: (value) =>
                        FormValidator.validateRequired(value, 'Hospital Name'),
                  ),
                  const SizedBox(height: 23),

                  // Mobile Number Field
                  CustomTextField(
                    label: 'Mobile Number *',
                    hint: '01XXXXXXXXX',
                    keyboardType: TextInputType.phone,
                    controller: _mobileController,
                    validator: FormValidator.validateMobile,
                  ),
                  const SizedBox(height: 23),

                  // Email Field
                  CustomTextField(
                    label: 'Email *',
                    hint: 'example@domain.com',
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                    validator: FormValidator.validateEmail,
                  ),
                  const SizedBox(height: 23),

                  // Governate & City Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomDropdownField(
                              label: 'Governate *',
                              hint: 'Select Governate',
                              items: governates,
                              value: selectedGovernate,
                              validator: (value) => null,
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedGovernate = newValue;
                                  selectedCity = null;
                                  _governateError = null;
                                });
                              },
                            ),
                            if (_governateError != null)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 4,
                                  left: 12,
                                ),
                                child: Text(
                                  _governateError!,
                                  style: const TextStyle(
                                    color: AppColors.errorRed,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomDropdownField(
                              label: 'City *',
                              hint: 'Select City',
                              items: availableCities,
                              isDisabled: isCityDropdownDisabled,
                              value: selectedCity,
                              onTap: _handleCityDropdownTap,
                              validator: (value) => null,
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedCity = newValue;
                                  _cityError = null;
                                });
                              },
                            ),
                            if (_cityError != null)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 4,
                                  left: 12,
                                ),
                                child: Text(
                                  _cityError!,
                                  style: const TextStyle(
                                    color: AppColors.errorRed,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 23),

                  // Location Link Field (Optional)
                  CustomTextField(
                    label: 'Location Link (Optional)',
                    hint: 'Get your location link from Google Maps',
                    keyboardType: TextInputType.url,
                    controller: _locationLinkController,
                    validator: (value) => null, // Optional field
                  ),
                  const SizedBox(height: 40),

                  // Submit Button
                  BlocBuilder<HospitalCubit, HospitalState>(
                    builder: (context, state) {
                      final isLoading = state is HospitalLoading;
                      return CustomElevatedButton(
                        onPressed: isLoading ? null : _submitForm,
                        width: double.infinity,
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Confirm',
                                style: AppTextStyles.buttonTextStyle,
                              ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Parse error message to show user-friendly text
  String _parseErrorMessage(String error) {
    if (error.contains('phone_number') && error.contains('not-null')) {
      return 'Mobile number is required. Please enter a valid phone number.';
    }
    if (error.contains('duplicate') || error.contains('already exists')) {
      return 'A profile with this information already exists.';
    }
    if (error.contains('network') || error.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    }
    // Return cleaned error
    if (error.contains('PostgrestException')) {
      final match = RegExp(r'message: ([^,]+)').firstMatch(error);
      if (match != null) {
        return match.group(1) ?? error;
      }
    }
    return error;
  }
}
