import 'package:app/pages/testing_profile.dart';
import 'package:app/pages/user_listings_page.dart';
import 'package:app/pages/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:app/pages/donors_page.dart';

// import 'package:app/pages/edit_profile.dart';
import 'package:app/pages/home_page.dart';
import 'package:app/pages/onboarding_screen.dart';
import 'package:app/pages/otp_screen.dart';

// import 'package:app/pages/requests_page.dart';
import 'package:app/pages/settings.dart';
import 'package:app/pages/signin.dart';
import 'package:app/pages/signup.dart';

Map<String, WidgetBuilder> routes = {
  "onboard": (context) => OnboardingScreen(),
  "home": (context) => HomePage(),
  "login": (context) => SignInScreen(),
  "signup": (context) => SignupPage(),
  "otp": (context) => OtpScreen(),
  "profile": (context) => ProfileScreen(),
  "dummyProfile": (context) => TestingProfile(),
  // "edit-profile": (context) => EditProfileScreen(),
  "settings": (context) => SettingsScreen(),
  "donors": (context) => DonorsPage(),
  "user-listing": (context) => UserListingsPage(),
  // "requests": (context) => RequestsPage(),
};
