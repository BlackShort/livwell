import 'package:get/get.dart';
import 'package:livwell/app/activity/pages/activity_page.dart';
import 'package:livwell/app/auth/pages/auth_wrapper.dart';
import 'package:livwell/app/base/pages/base_page.dart';
import 'package:livwell/app/home/pages/home_page.dart';
import 'package:livwell/app/notification/notification_page.dart';
import 'package:livwell/app/profile/pages/profile_page.dart';
import 'package:livwell/app/registration/pages/registration_page.dart';
import 'package:livwell/config/routes/route_names.dart';

import 'package:livwell/app/auth/pages/login_page.dart';
import 'package:livwell/app/auth/pages/signup_page.dart';

class Routes {
  static final List<GetPage> routes = [

    // ----------Auth Routes----------
    GetPage(name: AppRoute.wrapper, page: () => AuthWrapper()),
    GetPage(name: AppRoute.signup, page: () => const SignupPage()),
    GetPage(name: AppRoute.login, page: () => const LoginPage()),

    // ----------App Routes----------
    GetPage(name: AppRoute.base, page: () => const BasePage()),

    // ----------Base Routes----------
    GetPage(name: AppRoute.home, page: () => HomePage()),
    GetPage(name: AppRoute.register, page: () => RegistrationPage()),
    GetPage(name: AppRoute.activity, page: () => const ActivityPage()),
    GetPage(name: AppRoute.notification, page: () => const NotificationPage()),
    GetPage(name: AppRoute.profile, page: () => const ProfilePage()),

    // ----------Home Routes----------
    // GetPage(name: AppRoute.referralList, page: () => ReferralList()),

    // // ----------Profile Routes----------
    // GetPage(name: AppRoute.setProfile, page: () => const ProfileSetup()),
    // GetPage(name: AppRoute.profileUpdate, page: () => const ProfileUpdate()),
    // GetPage(
    //     name: AppRoute.claimReferral, page: () => const ClaimReferralPage()),
    // GetPage(name: AppRoute.feedback, page: () => const FeedbackPage()),
    // GetPage(name: AppRoute.settings, page: () => const SettingsPage()),
    // GetPage(name: AppRoute.about, page: () => const AboutUsPage()),
    // GetPage(name: AppRoute.help, page: () => const HelpAndSupportPage()),
  ];
}
