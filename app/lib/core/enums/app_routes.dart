enum AppRoutes {
  login,
  signup,
  onboarding,
  home,
  otp,
  profile,
  settings,
  donors,
  map,
  splash
}

extension AppRoutesExtension on AppRoutes {
  String get path {
    switch (this) {
      case AppRoutes.login:
        return "/login";
      case AppRoutes.signup:
        return "/signup";
      case AppRoutes.onboarding:
        return "/onboarding";
      case AppRoutes.home:
        return "/home";
      case AppRoutes.otp:
        return "/otp";
      case AppRoutes.profile:
        return "/profile";
      case AppRoutes.settings:
        return "/settings";
      case AppRoutes.donors:
        return "/donors";
      case AppRoutes.map:
        return "/map";
      case AppRoutes.splash:
        return "/splash";
    }
  }
}
