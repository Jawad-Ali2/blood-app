import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/enums/app_routes.dart';
import 'create_request_dialog.dart';

class BloodNavBar extends StatelessWidget {
  final userRole;

  BloodNavBar({super.key, this.userRole});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.grey[300],
      shape: CircularNotchedRectangle(),
      child: IconTheme(
        data: IconThemeData(color: Colors.black),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              tooltip: 'Home',
              icon: const Icon(Icons.home),
              onPressed: () {
                if (userRole != null && userRole.contains('donor')) {
                  context.push(AppRoutes.donorHome.path);
                } else {
                  context.push(AppRoutes.home.path);
                }
              },
            ),
            IconButton(
              tooltip: 'Profile',
              icon: const Icon(Icons.person),
              onPressed: () {
                context.push(AppRoutes.profile.path);
              },
            ),
            IconButton(
              tooltip: 'Settings',
              icon: const Icon(Icons.settings),
              onPressed: () {
                context.push(AppRoutes.settings.path);
              },
            ),IconButton(
              tooltip: 'Switch Mode',
              icon: const Icon(Icons.swap_horiz),
              onPressed: () {
                // context.push(AppRoutes.settings.path);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class NavBarFloatingButton extends StatelessWidget {
  const NavBarFloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.red,
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CreateRequestDialog(
              onRequestCreated: (dynamic result) {
                // Handle the result of creating a request
                if (result is Map &&
                    result['action'] == 'navigate_to_listings') {
                  Navigator.of(context).pop();
                  context.push('/user-listings');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text("Please manage your existing listings first"),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            );
          },
        );
      },
      shape: CircleBorder(),
      child: const Icon(
        Icons.add,
        color: Colors.white,
      ),
    );
  }
}
