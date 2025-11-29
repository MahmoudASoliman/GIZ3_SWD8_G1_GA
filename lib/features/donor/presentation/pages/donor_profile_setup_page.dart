import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_dropdown_field.dart';
import '../../../../core/widgets/custom_profile_header.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../models/donor_data.dart';
import '../../../../models/location_data.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../cubit/donor_cubit.dart';
import '../cubit/donor_state.dart';

class DonorProfileSetupPage extends StatefulWidget {
  const DonorProfileSetupPage({super.key});

  @override
  State<DonorProfileSetupPage> createState() => _DonorProfileSetupPageState();
}

class _DonorProfileSetupPageState extends State<DonorProfileSetupPage> {
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;

  // Text Controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  // Dropdown state variables
  String? selectedGovernate;
  String? selectedCity;
  String? selectedBloodGroup;
  String? selectedGender;

  // Dropdown errors
  String? _governateError;
  String? _cityError;
  String? _bloodGroupError;
  String? _genderError;

  // Data initialization
  late final List<String> governates = LocationData.governateCityMap.keys
      .toList();
  final List<String> bloodGroups = DonorData.bloodGroups;
  final List<String> genders = DonorData.genders;

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileController.dispose();
    _ageController.dispose();
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

    if (selectedBloodGroup == null || selectedBloodGroup!.isEmpty) {
      _bloodGroupError = 'Please select blood group';
      isValid = false;
    } else {
      _bloodGroupError = null;
    }

    if (selectedGender == null || selectedGender!.isEmpty) {
      _genderError = 'Please select gender';
      isValid = false;
    } else {
      _genderError = null;
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
        context.read<DonorCubit>().createProfile(
          userId: authState.user.id,
          fullName: _fullNameController.text.trim(),
          age: int.parse(_ageController.text.trim()),
          gender: selectedGender!,
          bloodGroup: selectedBloodGroup!,
          mobile: _mobileController.text.trim(),
          governate: selectedGovernate!,
          city: selectedCity!,
        );
      }
    }
  }

  void _handleCityDropdownTap() {
    if (selectedGovernate == null) {
      _showErrorSnackbar(context, 'Please select a governate first.');
    }
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
    if (error.contains('PostgrestException')) {
      final match = RegExp(r'message: ([^,]+)').firstMatch(error);
      if (match != null) {
        return match.group(1) ?? error;
      }
    }
    return error;
  }

  @override
  Widget build(BuildContext context) {
    final List<String> availableCities = selectedGovernate != null
        ? LocationData.governateCityMap[selectedGovernate] ?? []
        : [];
    final bool isCityDropdownDisabled = selectedGovernate == null;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          'Profile Setup',
          style: TextStyle(
            color: AppColors.red,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: false,
        titleSpacing: 20,
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: BlocListener<DonorCubit, DonorState>(
        listener: (context, state) async {
          if (state is DonorProfileCreated) {
            _showSuccessSnackbar(context, 'Profile created successfully!');

            // Subscribe to blood group topic for notifications
            try {
              final notificationService = getIt<NotificationService>();
              await notificationService.subscribeToBloodGroup(
                state.profile.bloodGroup,
              );
            } catch (e) {
              // Error subscribing to blood group silently handled
            }

            if (context.mounted) {
              context.go('/donor-home');
            }
          } else if (state is DonorError) {
            _showErrorSnackbar(context, _parseErrorMessage(state.message));
          }
        },
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
                  const ProfileHeader(
                    imageWidget: Image(image: AssetImage('assets/Person.png')),
                    labelText: 'Donor',
                    backgroundColor: AppColors.lightRed,
                  ),
                  const SizedBox(height: 33),

                  // Full Name
                  CustomTextField(
                    label: 'Full Name *',
                    hint: 'Enter your full name',
                    keyboardType: TextInputType.name,
                    controller: _fullNameController,
                    validator: (value) =>
                        FormValidator.validateRequired(value, 'Full Name'),
                  ),
                  const SizedBox(height: 23),

                  // Mobile Number
                  CustomTextField(
                    label: 'Mobile Number *',
                    hint: '01XXXXXXXXX',
                    keyboardType: TextInputType.phone,
                    controller: _mobileController,
                    validator: FormValidator.validateMobile,
                  ),
                  const SizedBox(height: 23),

                  // Governate and City
                  Row(
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

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Age
                      Expanded(
                        flex: 1,
                        child: CustomTextField(
                          label: 'Age *',
                          hint: '20',
                          keyboardType: TextInputType.number,
                          controller: _ageController,
                          validator: FormValidator.validateAge,
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Blood Group
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomDropdownField(
                              label: 'Blood *',
                              hint: 'A+',
                              items: bloodGroups,
                              value: selectedBloodGroup,
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedBloodGroup = newValue;
                                  _bloodGroupError = null;
                                });
                              },
                            ),
                            if (_bloodGroupError != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4, left: 4),
                                child: Text(
                                  _bloodGroupError!,
                                  style: const TextStyle(
                                    color: AppColors.errorRed,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Gender
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomDropdownField(
                              label: 'Gender *',
                              hint: 'Male',
                              items: genders,
                              value: selectedGender,
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedGender = newValue;
                                  _genderError = null;
                                });
                              },
                            ),
                            if (_genderError != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4, left: 4),
                                child: Text(
                                  _genderError!,
                                  style: const TextStyle(
                                    color: AppColors.errorRed,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),

                  BlocBuilder<DonorCubit, DonorState>(
                    builder: (context, state) {
                      final isLoading = state is DonorLoading;
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
}
