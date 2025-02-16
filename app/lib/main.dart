import 'package:app/core/network/dio_client.dart';
import 'package:app/core/storage/secure_storage.dart';
import 'package:app/pages/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  GetIt.instance.registerSingleton<SecureStorage>(SecureStorage());
  GetIt.instance.registerSingleton<DioClient>(DioClient());
  // await Hive.initFlutter();
  
  // Hive.registerAdapter();
  runApp(const BloodApp());
}

class BloodApp extends StatelessWidget {
  const BloodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DonorX',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: OnboardingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
