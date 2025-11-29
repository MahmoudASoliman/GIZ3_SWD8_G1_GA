class AppStrings {
  // App
  static const String appName = 'Blood Donation';

  // Auth
  static const String login = 'Log in';
  static const String signUp = 'Sign up';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String continueText = 'Continue';
  static const String donor = 'Donor';
  static const String hospital = 'Hospital';
  static const String dontHaveAccount = "Don't have an account? ";
  static const String alreadyHaveAccount = "Already have an account? ";
  static const String loginWithGoogle = 'Login with Google';
  static const String or = 'Or';

  // Errors
  static const String serverError = 'Server error occurred';
  static const String networkError = 'No internet connection';
  static const String unknownError = 'An unknown error occurred';
  static const String validationError = 'Please check your input';
  static const String invalidOtp = 'Invalid OTP code';
  static const String otpExpired = 'OTP has expired';
  static const String donationNotFound = 'Donation not found';
  static const String requestNotAvailable = 'Request is no longer available';
  static const String alreadyHavePendingDonation =
      'You already have a pending donation for this request';

  // Success
  static const String loginSuccess = 'Login successful';
  static const String signupSuccess = 'Account created successfully';
  static const String profileUpdated = 'Profile updated successfully';
  static const String requestCreated = 'Request created successfully';
  static const String requestAccepted = 'Request accepted successfully';
  static const String donationOfferCreated = 'Donation offer sent successfully';
  static const String donationAccepted = 'Donation accepted';
  static const String donationRejected = 'Donation rejected';
  static const String donationCompleted = 'Donation completed successfully';
  static const String otpVerified = 'OTP verified successfully';

  // Home Screen
  static const String home = 'Home';
  static const String requests = 'Requests';
  static const String profile = 'Profile';
  static const String saveALife = 'Save a life';
  static const String giveBlood = 'Give Blood';
  static const String donateNow = 'Donate NOW';
  static const String makeRequest = 'Make a Request';
  static const String blogs = 'Blogs';

  // Requests Screen
  static const String donationRequests = 'Donation Requests';
  static const String shareYourBlood = 'Share your Blood';
  static const String saveLife = 'Save Life';
  static const String addNewRequest = 'Add New Request';
  static const String findMeHere = 'find me here';
  static const String noRequestsYet = 'No requests yet';
  static const String refreshRequests = 'Refresh requests';

  // Request Details
  static const String requestDetails = 'Request Details';
  static const String patientName = 'Patient Name';
  static const String bloodGroup = 'Blood Group';
  static const String roomNumber = 'Room Number';
  static const String companionNumber = 'Companion Number';
  static const String hospitalName = 'Hospital Name';
  static const String governate = 'Governate';
  static const String city = 'City';
  static const String hospitalNumber = 'Hospital Number';
  static const String locationLink = 'Location Link';

  // Create Request
  static const String createRequest = 'Create Request';
  static const String requestNow = 'Request Now';
  static const String companionMobileNumber = 'Companion Mobile Number';
  static const String enterPatientName = 'Enter patient name';
  static const String enterRoomNumber = 'Enter room number';
  static const String selectBloodGroup = 'Select blood group';
  static const String enterCompanionMobile = 'Enter companion mobile';

  // Donation System
  static const String donationOffers = 'Donation Offers';
  static const String noDonationOffers = 'No donation offers yet';
  static const String pendingDonations = 'Pending Donations';
  static const String accept = 'Accept';
  static const String reject = 'Reject';
  static const String otpCode = 'OTP Code';
  static const String expiresIn = 'Expires in';
  static const String enterOtp = 'Enter OTP Code';
  static const String enterOtpHint = 'Contact hospital to get the code';
  static const String confirmDonation = 'Confirm Donation';
  static const String verifyOtp = 'Verify OTP';
  static const String donorInfo = 'Donor Information';
  static const String contactDonor = 'Contact Donor';
  static const String donorName = 'Donor Name';
  static const String donorPhone = 'Phone';
  static const String donorEmail = 'Email';

  // Donation Status
  static const String statusPending = 'Pending';
  static const String statusAccepted = 'Accepted';
  static const String statusRejected = 'Rejected';
  static const String statusCompleted = 'Completed';
  static const String statusExpired = 'Expired';
  static const String statusCancelled = 'Cancelled';

  // Notifications
  static const String notifications = 'Notifications';
  static const String noNotifications = 'No Notifications Yet';
  static const String markAsRead = 'Mark as read';
  static const String markAllAsRead = 'Mark all as read';

  // Notification Messages
  static const String notifNewRequestTitle = 'New Blood Request';
  static String notifNewRequestBody(String hospital, String bloodGroup) =>
      '$hospital needs blood type $bloodGroup';
  static const String notifDonationOfferTitle = 'New Donation Offer';
  static String notifDonationOfferBody(String donorName, String otp) =>
      '$donorName wants to donate - OTP: $otp';
  static const String notifDonationAcceptedTitle = 'Donation Accepted';
  static const String notifDonationAcceptedBody =
      'Your donation offer has been accepted. Please contact the hospital.';
  static const String notifDonationRejectedTitle = 'Donation Rejected';
  static const String notifDonationRejectedBody =
      'Your donation offer was rejected.';
  static const String notifDonationCompletedTitle = 'Donation Completed';
  static const String notifDonationCompletedBody =
      'Thank you for your donation!';
  static const String notifOtpExpiredTitle = 'OTP Expired';
  static String notifOtpExpiredBody(String donorName) =>
      'OTP for $donorName has expired';

  // Profile
  static const String editProfile = 'Edit Profile';
  static const String logout = 'Logout';
  static const String fullName = 'Full Name';
  static const String phoneNumber = 'Phone Number';
  static const String age = 'Age';
  static const String gender = 'Gender';
  static const String male = 'Male';
  static const String female = 'Female';
  static const String address = 'Address';
  static const String available = 'Available';
  static const String notAvailable = 'Not Available';
  static const String lastDonationDate = 'Last Donation Date';
  static const String completeYourProfile = 'Complete Your Profile';
  static const String saveProfile = 'Save Profile';

  // (Benefits of Blood Donation) ---
  static const String benefitsScreenTitle = 'Benefits of Blood Donation';
  static const String benefitsSectionHeader = 'Health benefits for donors';

  static const String benefit1Title = 'Mini-physical and wellness checkup:';
  static const String benefit1Body =
      'Before donating, you receive a free health screening that checks your blood pressure, pulse, temperature, and hemoglobin levels. This can help detect potential health issues like high blood pressure or anemia. For whole blood donations, you may also have your cholesterol levels checked.';

  static const String benefit2Title = 'Reduced risk of cardiovascular disease:';
  static const String benefit2Body =
      'Regular blood donation helps maintain healthy iron levels and decreases blood viscosity (thickness). Both of these factors reduce the risk of heart attacks and strokes.';

  static const String benefit3Title = 'Balanced iron levels:';
  static const String benefit3Body =
      ' The donation process reduces the amount of iron in your blood. While iron is essential, excessive levels can lead to health problems like atherosclerosis, or hardened arteries. This is particularly beneficial for those with high iron levels or the genetic disorder hemochromatosis.';

  static const String benefit4Title = 'Encourages red blood cell production:';
  static const String benefit4Body =
      'After donating, your body replaces the lost blood cells by stimulating the bone marrow. This process keeps your system healthy and balanced.';

  static const String benefit5Title = 'Weight management (mild):';
  static const String benefit5Body =
      'Your body burns approximately 650 calories to replenish a pint of donated blood. While this is not a significant weight-loss method, it is a bonus for repeat donors.';
  // lib/core/constants/app_strings.dart

  // --- (Conditions of Blood Donation) ---
  static const String conditionsScreenTitle = 'Conditions of Blood Donation';

  static const String generalConditionsHeader = 'General conditions to be met';
  static const String temporaryDeferralHeader =
      'Conditions requiring temporary deferral';
  static const String deferralIntroText =
      'You may have to wait a period of time before donating if:';

  static const String generalCondition1Title = 'Age and Weight:';
  static const String generalCondition1Body =
      'Donors must generally be in good health, be at least 17 years old (or 16 with parental consent in some areas), and weigh at least 110 pounds.';

  static const String generalCondition2Title = 'Overall Health:';
  static const String generalCondition2Body =
      'You must be feeling well on the day of donation. You cannot donate if you have a cold, flu, or other active infection.';

  static const String generalCondition3Title = 'Hemoglobin Level:';
  static const String generalCondition3Body =
      'Your hemoglobin (iron) levels are checked before donation. If they are too low, you may be deferred to prevent anemia.';

  static const String deferralCondition1Title = 'Medical Procedures:';
  static const String deferralCondition1Body =
      'You recently had a tattoo or piercing (a 3- to 6-month wait is common), dental work, or minor surgery.';

  static const String deferralCondition2Title = 'Travel:';
  static const String deferralCondition2Body =
      'You have recently traveled to a region where certain diseases like malaria or the Zika virus are endemic.';

  static const String deferralCondition3Title = 'Medications:';
  static const String deferralCondition3Body =
      'You are taking certain medications, such as some antibiotics or HIV prevention drugs.';

  static const String deferralCondition4Title = 'Pregnancy:';
  static const String deferralCondition4Body =
      'Pregnant individuals are not eligible to donate, and a waiting period applies after childbirth.';

  //  (Recovery After Donation) ---
  static const String recoveryScreenTitle = 'Recovery After Donation';

  static const String immediateRecoveryHeader = 'Immediate recovery';
  static const String longTermRecoveryHeader = 'Long-term recovery';

  static const String immediate1Title = 'Drink fluids:';
  static const String immediate1Body =
      'Drink plenty of extra, non-alcoholic fluids in the 24 hours after donating.';

  static const String immediate2Title = 'Eat snacks:';
  static const String immediate2Body =
      'Have the snack offered at the donation center to restore your blood sugar levels.';

  static const String immediate3Title = 'Avoid strenuous activity:';
  static const String immediate3Body =
      'For at least 24 hours, avoid heavy lifting or vigorous exercise.';

  static const String immediate4Title = 'Manage dizziness:';
  static const String immediate4Body =
      'If you feel light-headed, sit or lie down with your feet up until you feel better.';

  static const String immediate5Title = 'Keep the bandage on:';
  static const String immediate5Body =
      'Leave the pressure bandage on your arm for a few hours to prevent bruising.';

  static const String longTerm1Title = 'Eat iron-rich foods:';
  static const String longTerm1Body =
      'Include foods like lean meat, fish, leafy greens, beans, and iron-fortified cereals in your diet.';

  static const String longTerm2Title = 'Consider supplements:';
  static const String longTerm2Body =
      'Frequent donors may need an iron supplement to rebuild iron stores, but should consult a doctor first.';

  static const String longTerm3Title = 'Rest:';
  static const String longTerm3Body =
      'Listen to your body and avoid overexertion until your energy levels return to normal.';
}
