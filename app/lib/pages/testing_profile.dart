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

  String? accessToken;
  String? refreshToken;

  Future<void> getToken() async {
    String? fetchedAToken = await storage.getAccessToken();
    String? fetchedRToken = await storage.getRefreshToken();
    setState(() {
      accessToken = fetchedAToken;
      refreshToken = fetchedRToken;
    });
  }

  Future<void> clearTokens() async {
    await storage.clearStorage();

    setState(() {
      accessToken = '';
      refreshToken = '';
    });
  }

  Future<void> deleteAT() async {
    storage.clearAT();

    setState(() {
      accessToken = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Text(accessToken ?? "No Token Yet"),
          Text(refreshToken ?? "No Token Yet"),
          FilledButton(onPressed: getToken, child: Text("Get Tokens")),
          FilledButton(onPressed: deleteAT, child: Text("Clear Token")),
          FilledButton(onPressed: clearTokens, child: Text("Clear Token"))
        ],
      ),
    );
  }
}
