import 'package:app/core/enums/app_routes.dart';
import 'package:app/pages/LoginSignup.dart';
import 'package:app/pages/donors_page.dart';
import 'package:app/pages/home_page.dart';
import 'package:app/pages/onboarding_screen.dart';
import 'package:app/pages/otp_screen.dart';
import 'package:app/pages/settings.dart';
import 'package:app/pages/signin.dart';
import 'package:app/pages/signup.dart';
import 'package:app/pages/splash_screen.dart';
import 'package:app/pages/user_profile.dart';
import 'package:app/services/auth_services.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash.path,
    // redirect: (context, state) async {
    //   print("KLJGLKGJDGKLJGSLKGJDLKGj");
    //   bool isLoggedIn = await AuthService().isUserLoggedIn();
    //
    //   if (isLoggedIn) {
    //     return AppRoutes.home.path;
    //   } else {
    //     return AppRoutes.onboarding.path;
    //   }
    // },
    routes: [
      GoRoute(
          path: AppRoutes.login.path,
          builder: (context, state) => SignInScreen()),
      GoRoute(
          path: AppRoutes.signup.path,
          builder: (context, state) => SignupPage()),
      GoRoute(
          path: AppRoutes.onboarding.path,
          builder: (context, state) => OnboardingScreen()),
      GoRoute(
          path: AppRoutes.home.path, builder: (context, state) => HomePage()),
      GoRoute(
          path: AppRoutes.otp.path, builder: (context, state) => OtpScreen()),
      GoRoute(
          path: AppRoutes.profile.path,
          builder: (context, state) => ProfileScreen()),
      GoRoute(
          path: AppRoutes.settings.path,
          builder: (context, state) => SettingsScreen()),
      GoRoute(
          path: AppRoutes.donors.path,
          builder: (context, state) => DonorsPage()),
      GoRoute(
          path: AppRoutes.splash.path,
          builder: (context, state) => SplashScreen()),
    ]);
