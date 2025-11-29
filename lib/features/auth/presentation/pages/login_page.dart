import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_profile_header.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onTapSignUp;

  const LoginPage({super.key, required this.onTapSignUp});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  UserType _selectedUserType = UserType.donor;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        expectedUserType: _selectedUserType,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const LoadingWidget(message: 'Logging in...');
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 24),

                    // User Type Selection
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () => setState(
                            () => _selectedUserType = UserType.donor,
                          ),
                          child: ProfileHeader(
                            imageWidget: Image.asset(
                              _selectedUserType == UserType.donor
                                  ? 'assets/Person.png'
                                  : 'assets/Person2.png',
                            ),
                            labelText: AppStrings.donor,
                            textColor: _selectedUserType == UserType.donor
                                ? AppColors.red
                                : AppColors.black,
                            backgroundColor: _selectedUserType == UserType.donor
                                ? AppColors.lightRed
                                : AppColors.lightGrey,
                          ),
                        ),
                        const SizedBox(width: 40),
                        GestureDetector(
                          onTap: () => setState(
                            () => _selectedUserType = UserType.hospital,
                          ),
                          child: ProfileHeader(
                            imageWidget: Image.asset(
                              _selectedUserType == UserType.donor
                                  ? 'assets/H2.png'
                                  : 'assets/H.png',
                            ),
                            labelText: AppStrings.hospital,
                            textColor: _selectedUserType == UserType.hospital
                                ? AppColors.red
                                : AppColors.black,
                            backgroundColor:
                                _selectedUserType == UserType.hospital
                                ? AppColors.lightRed
                                : AppColors.lightGrey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),

                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: AppStrings.email,
                        hintText: 'Enter your email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: FormValidator.validateEmail,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    const SizedBox(height: 20),

                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: AppStrings.password,
                        hintText: 'Enter your password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(
                              () => _isPasswordVisible = !_isPasswordVisible,
                            );
                          },
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_off_outlined
                                : Icons.remove_red_eye_outlined,
                          ),
                        ),
                      ),
                      validator: FormValidator.validatePassword,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    const SizedBox(height: 56),

                    // Login Button
                    CustomElevatedButton(
                      onPressed: _handleLogin,
                      child: Text(
                        AppStrings.continueText,
                        style: AppTextStyles.buttonTextStyle,
                      ),
                    ),
                    const SizedBox(height: 56),

                    // Google Login - Commented out for future use
                    // Row(
                    //   children: [
                    //     const Expanded(
                    //       child: Divider(
                    //         thickness: 1.5,
                    //         color: AppColors.greyBorder,
                    //       ),
                    //     ),
                    //     Padding(
                    //       padding: const EdgeInsets.symmetric(horizontal: 8),
                    //       child: Text(
                    //         "Or",
                    //         style: const TextStyle(
                    //           fontSize: 16,
                    //           fontWeight: FontWeight.w600,
                    //           fontFamily: 'Inter',
                    //           color: AppColors.greyBorder,
                    //         ),
                    //       ),
                    //     ),
                    //     const Expanded(
                    //       child: Divider(
                    //         thickness: 1.5,
                    //         color: AppColors.greyBorder,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    // const SizedBox(height: 30),
                    // GestureDetector(
                    //   onTap: () {
                    //   },
                    //   child: Container(
                    //     height: 56,
                    //     decoration: BoxDecoration(
                    //       color: AppColors.white,
                    //       borderRadius: BorderRadius.circular(12),
                    //       border: Border.all(
                    //         color: AppColors.greyBorder,
                    //         width: 2,
                    //       ),
                    //     ),
                    //     child: Row(
                    //       mainAxisAlignment: MainAxisAlignment.center,
                    //       children: [
                    //         const Image(image: AssetImage("assets/google.png")),
                    //         const SizedBox(width: 8),
                    //         const Text(
                    //           "Login with Google",
                    //           style: TextStyle(
                    //             fontSize: 16,
                    //             fontWeight: FontWeight.w600,
                    //             fontFamily: 'Inter',
                    //             color: AppColors.black,
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(height: 48),

                    // Sign Up Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          AppStrings.dontHaveAccount,
                          style: TextStyle(
                            color: AppColors.lightGrey,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                          ),
                        ),
                        InkWell(
                          onTap: widget.onTapSignUp,
                          child: const Padding(
                            padding: EdgeInsets.only(bottom: 2.0),
                            child: Text(
                              AppStrings.signUp,
                              style: TextStyle(
                                color: AppColors.red,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
