import 'package:app/core/enums/app_routes.dart';
import 'package:app/pages/donor_homepage.dart';
import 'package:app/pages/donors_page.dart';
import 'package:app/pages/home_page.dart';
import 'package:app/pages/listings_page.dart';
import 'package:app/pages/map_screen.dart';
import 'package:app/pages/onboarding_screen.dart';
import 'package:app/pages/otp_screen.dart';
import 'package:app/pages/settings.dart';
import 'package:app/pages/signin.dart';
import 'package:app/pages/signup.dart';
import 'package:app/pages/splash_screen.dart';
import 'package:app/pages/testing_profile.dart';
import 'package:app/pages/user_listings_page.dart';
import 'package:app/pages/user_profile.dart';
import 'package:go_router/go_router.dart';

final GoRouter router =
    GoRouter(initialLocation: AppRoutes.splash.path, routes: [
  GoRoute(
    path: AppRoutes.login.path,
    builder: (context, state) => SignInScreen(),
  ),
  GoRoute(
    path: AppRoutes.signup.path,
    builder: (context, state) => SignupPage(),
  ),
  GoRoute(
    path: AppRoutes.onboarding.path,
    builder: (context, state) => OnboardingScreen(),
  ),
  GoRoute(
    path: AppRoutes.home.path,
    builder: (context, state) => HomePage(),
  ),
  GoRoute(
    path: AppRoutes.otp.path,
    builder: (context, state) => OtpScreen(),
  ),
  GoRoute(
    path: AppRoutes.profile.path,
    builder: (context, state) => ProfileScreen(),
  ),
  GoRoute(
    path: AppRoutes.settings.path,
    builder: (context, state) => SettingsScreen(),
  ),
  GoRoute(
    path: AppRoutes.donors.path,
    builder: (context, state) => DonorsPage(),
  ),
  GoRoute(
    path: AppRoutes.map.path,
    builder: (context, state) => MapScreen(),
  ),
  GoRoute(
    path: AppRoutes.splash.path,
    builder: (context, state) => SplashScreen(),
  ),
  GoRoute(
    path: AppRoutes.dummyProfile.path,
    builder: (context, state) => TestingProfile(),
  ),
  GoRoute(
    path: AppRoutes.userListings.path,
    builder: (context, state) => UserListingsPage(),
  ),
  GoRoute(
    path: AppRoutes.donorHome.path,
    builder: (context, state) => DonorHomePage(),
  ),
  GoRoute(
    path: AppRoutes.bloodRequests.path,
    builder: (context, state) => BloodRequestsPage(),
  ),
]);
