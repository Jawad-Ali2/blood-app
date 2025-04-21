import 'package:flutter/material.dart';
import 'package:app/services/auth_services.dart';
import 'package:go_router/go_router.dart';
import 'package:app/core/enums/app_routes.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _authCheckCompleted = false;

  @override
  void initState() {
    super.initState();
    // Use a delayed initialization to avoid immediate heavy operations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthentication();
    });
  }

  Future<void> _checkAuthentication() async {
    // Add a timeout to prevent infinite waiting
    try {
      // Run auth check with timeout to prevent hanging
      bool isLoggedIn = false;
      List<String> userRoles = [];

      await Future.wait([
        () async {
          try {
            isLoggedIn = await AuthService().isUserLoggedIn();
          } catch (e) {
            print("Error checking login status: $e");
            isLoggedIn = false;
          }
        }(),
      ]).timeout(Duration(seconds: 10), onTimeout: () {
        print("Authentication check timed out");
        return [];
      });

      if (isLoggedIn && mounted) {
        try {
          userRoles = await AuthService().getUserRoles(context);
        } catch (e) {
          print("Error getting user roles: $e");
          userRoles = [];
        }
      }

      if (!mounted) return;
      setState(() => _authCheckCompleted = true);

      if (isLoggedIn) {
        print("ROLES: $userRoles");
        if (userRoles.contains('donor')) {
          context.go(AppRoutes.donorHome.path);
        } else {
          context.go(AppRoutes.home.path);
        }
      } else {
        context.go(AppRoutes.onboarding.path);
      }
    } catch (e) {
      print("Error during authentication check: $e");
      if (mounted) {
        context.go(AppRoutes.onboarding.path);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Load the logo from assets
            // Animate logo in for 2 seconds
            AnimatedOpacity(
              opacity: 1.0,
              duration: Duration(seconds: 2),
              child: Image.asset(
                'assets/images/logo.png',
                width: 300,
                height: 300,
              ),
            ),
            Text(
              "DonorX",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
