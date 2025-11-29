// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import '../../../../core/constants/app_colors.dart';
// import '../../../../core/constants/app_text_styles.dart';
// import '../../../../core/widgets/custom_button.dart';
// import '../../../../core/widgets/custom_app_bar.dart';
// import '../../../auth/presentation/cubit/auth_cubit.dart';
// import '../../../auth/presentation/cubit/auth_state.dart';

// /// Hospital Home Screen with original UI design
// class HospitalHomeScreen extends StatelessWidget {
//   final VoidCallback? onMakeRequestPressed;

//   const HospitalHomeScreen({super.key, this.onMakeRequestPressed});

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Column(
//         children: [
//           _buildHeader(context),
//           const SizedBox(height: 20),
//           _buildBanner(context),
//           const SizedBox(height: 10),
//           _buildBlogsSection(context),
//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }

//   Widget _buildHeader(BuildContext context) {
//     return BlocBuilder<AuthCubit, AuthState>(
//       builder: (context, state) {
//         String userName = 'Hospital';
//         if (state is AuthAuthenticated) {
//           userName = state.user.email.split('@').first;
//         }
//         return CustomHomeAppBar(
//           userName: userName,
//           onNotificationPressed: () => context.push('/notifications'),
//         );
//       },
//     );
//   }

//   Widget _buildBanner(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//       child: Container(
//         width: double.infinity,
//         decoration: const BoxDecoration(color: Colors.white),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 Image.asset('assets/donation.png', height: 139, width: 200),
//                 const Expanded(
//                   child: Text(
//                     'Save a life\nGive Blood',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       fontFamily: 'Inter',
//                       color: AppColors.black,
//                       height: 1.2,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 30),
//             CustomElevatedButton(
//               onPressed: onMakeRequestPressed ?? () {},
//               width: 170,
//               child: const Text(
//                 'Make a Request',
//                 style: AppTextStyles.buttonTextStyle,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBlogsSection(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Blogs',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.w600,
//               fontFamily: 'Poppins',
//               color: AppColors.black,
//             ),
//           ),
//           const SizedBox(height: 15),
//           _buildBlogItem(
//             context: context,
//             iconPath: 'assets/benifits.png',
//             title: 'Benefits of Blood Donation',
//             onTap: () => context.push('/blog1'),
//           ),
//           _buildBlogItem(
//             context: context,
//             iconPath: 'assets/conditions.png',
//             title: 'Conditions of Blood Donation',
//             onTap: () => context.push('/blog2'),
//           ),
//           _buildBlogItem(
//             context: context,
//             iconPath: 'assets/recovery.png',
//             title: 'Recovery After Donation',
//             onTap: () => context.push('/blog3'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBlogItem({
//     required BuildContext context,
//     required String iconPath,
//     required String title,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 15),
//         padding: const EdgeInsets.all(15),
//         decoration: BoxDecoration(
//           color: AppColors.white,
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(color: AppColors.lightGrey),
//         ),
//         child: Row(
//           children: [
//             Image.asset(iconPath, height: 64, width: 64),
//             const SizedBox(width: 5),
//             Expanded(
//               child: Text(
//                 title,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   fontFamily: 'Inter',
//                   color: AppColors.black,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
