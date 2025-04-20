import 'package:app/core/storage/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/enums/app_routes.dart';
import '../services/auth_services.dart';

class BloodAppBar extends StatelessWidget implements PreferredSizeWidget {
  final _storage = GetIt.instance.get<SecureStorage>();
  final String title;
  final Widget? action;
  final bool showBackButton;

  BloodAppBar({
    super.key,
    this.title = "DonorX",
    this.action,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 70,
      backgroundColor: Colors.red[600],
      title: Text(
        "DonorX",
        style: GoogleFonts.dmSans(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: false,
      actions: [
        // Username display
        FutureBuilder<User?>(
          future: _storage.getUser(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  "Loading...",
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  "Guest",
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                snapshot.data!.username,
                style: GoogleFonts.dmSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          },
        ),

        // Logout icon button
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: () {
            // Show logout confirmation dialog
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Logout"),
                  content: Text("Are you sure you want to logout?"),
                  actions: [
                    TextButton(
                      child: Text("Cancel"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child:
                          Text("Logout", style: TextStyle(color: Colors.red)),
                      onPressed: () async {
                        final isLoggedOut =
                            await AuthService().signOut(context);

                        Navigator.of(context).pop();
                        if (isLoggedOut) {
                          context.go(AppRoutes.login.path);
                        }
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(70);
}
