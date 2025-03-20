// constants.dart
class AppConstants {
  // App related strings

  // ------------main.dart-----------//
  static const String appName = 'LivWell';
  static const String apple = 'assets/images/apple.png';
  static const String google = 'assets/images/google.png';
  static const String applogo = 'assets/logo/livwell_logo.png';
  static const String dog = 'assets/svgs/dog.svg';
  static const String kids = 'assets/svgs/kids.svg';


  // ------------onboard.dart-----------//
  static const String welcomeAppName = 'MoneyCart';
  static const String welcomeMessage = 'Apna Paisa Haq Se Maango';
  static const String startButton = 'Get Started';
  static const String loginButton = 'Login';
  static const String onboardImg = 'assets/images/onboard.png';

  // ------------sign_in_screen.dart-----------//
  static const String signinHeading = 'Sign In.';
  static const String signinButton = 'Sign In';
  static const String loginsignupImg = 'assets/icons/mainlogo.png';
  static const String signupText = ' Sign Up';
  static const String accountText = 'Don\'t have an account?';

  // ------------sign_up_screen.dart-----------//
  static const String signipHeading = 'Sign Up.';
  static const String signupButton = 'Sign Up';
  static const String referralText = 'Have Referral Code';
  static const String signinText = ' Sign In';
  static const String alreadyText = 'Already have an account?';

  // ------------forget_pass_screen.dart-----------//
  static const String forgetPasssHeading = 'Forget Password?';
  static const String forgetPasssTitle = 'Make Selection';
  static const String forgetPasssSubTitle =
      'Select one of the options given below to reset your password.';
  static const String forgetOption = 'E-Mail';
  static const String forgetOptionText = 'Reset via Mail Verification';
  static const String forgetImg = 'assets/images/forgetpass.png';
  static const String otpImg = 'assets/images/otp.png';

  // ------------home_screen.dart-----------//
  static const String mainHeading = 'Select a Service';
  static const String serviceOpt1 = 'TDS Refund';
  static const String serviceOpt1Img = 'assets/images/refund.png';
  static const String serviceOpt2 = 'PF';
  static const String serviceOpt2Img = 'assets/images/pf.png';
  static const String serviceOpt3 = 'Loan';
  static const String serviceOpt3Img = 'assets/images/loan.png';
  static const String serviceOpt4 = 'Insurance';
  static const String serviceOpt4Img = 'assets/images/insurance.png';

  // ------------rewards.dart-----------//
  static const String tab1 = 'Referral';
  static const String tab2 = 'How it works';
  static const String shareTitle = 'Register on MoneyCart!';
  static const String referrlImg = 'assets/icons/refer.svg';
  static const String referrlButton = 'Refer and Earn';
  static const String referralSubTitle =
      'Invite a friend, family member, or colleague and earn ₹50/- per referral."';
  static const String referralMessage =
      'Share your unique referral link with your network. When they sign up and use MoneyCart services, you both earn rewards!';
  static const String step1 =
      'Invite a friend or family by clicking on the Refer and Earn button and share the link via WhatsApp or SMS.';
  static const String step2 =
      'Once your friend or family downloads the app and registers for the service, you would be notified.';
  static const String step3 =
      'For every service used by them, you would get a ₹50/- cash back.';

  // ------------tds_otp.dart-----------//
  static const String tdsotperror =
      'Please wait until the MoneyCart team connects you';

  // ------------tds_otp.dart-----------//
  static const String tdsdetialserror =
      'Please wait until the MoneyCart team connects you';

  // ------------tds_final_otp.dart-----------//
  static const String TdsFinalOtp =
      'Please wait until the MoneyCart team connects you';

  // ------------tds_payment.dart-----------//
  static const String payment = 'assets/images/paymentQR.jpg';
  static const String taxImg = 'assets/images/paymentQR.jpg';

  // ------------tds_details.dart-----------//
  static const String processing = 'assets/images/processing.png';

  // Error messages
  static const String networkError = 'Please check your internet connection.';
  static const String loginError = 'Invalid username or password.';

  // Image paths
  static const String backgroundImagePath = 'assets/images/background.png';

  // Video paths
  static const String introVideoPath = 'assets/videos/intro.mp4';

  // Other constants
  static const double defaultPadding = 16.0;
  static const double avatarRadius = 50.0;

  // URL endpoints
  static const String baseUrl = 'https://api.myflutterapp.com';
  static const String loginEndpoint = '/auth/login';
  static const String signupEndpoint = '/auth/signup';

}