import 'package:flutter/material.dart';
import 'package:app/services/auth_services.dart';
import 'package:go_router/go_router.dart';
import 'package:app/core/enums/app_routes.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    await Future.delayed(Duration(seconds: 2)); // Simulate loading time
    bool isLoggedIn = await AuthService().isUserLoggedIn();

    if (mounted) {
      if (isLoggedIn) {
        // context.go(AppRoutes.home.path);
        context.go(AppRoutes.dummyProfile.path);
      } else {
        context.go(AppRoutes.onboarding.path);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
