import 'package:app/core/storage/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class TestingProfile extends StatefulWidget {
  const TestingProfile({super.key});

  @override
  _TestingProfile createState() => _TestingProfile();
}

class _TestingProfile extends State<TestingProfile> {
  final storage = GetIt.instance.get<SecureStorage>();

  String? token;

  Future<void> getToken() async {
    String? fetchedToken = await storage.getAccessToken();
    setState(() {
      token = fetchedToken; // Update token inside setState
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Text(token ?? "No Token Yet"),
          FilledButton(onPressed: getToken, child: Text("Get Token"))
        ],
      ),
    );
  }
}
