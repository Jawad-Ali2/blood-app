import 'package:app/core/network/dio_client.dart';
import 'package:app/core/storage/secure_storage.dart';
import 'package:app/pages/onboarding_screen.dart';
import 'package:app/router.dart';
import 'package:app/routes/routes.dart';
import 'package:app/pages/testing_profile.dart';
import 'package:app/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  GetIt.instance.registerSingleton<SecureStorage>(SecureStorage());
  GetIt.instance.registerSingleton<DioClient>(DioClient());
  // await Hive.initFlutter();
  // Hive.registerAdapter();
  runApp(const BloodApp());
}

class BloodApp extends StatefulWidget {
  const BloodApp({super.key});

  @override
  _BloodAppState createState() => _BloodAppState();
}

class _BloodAppState extends State<BloodApp> {
  // Future<bool>? _isLoggedIn;

  @override
  void initState() {
    super.initState();
    // _isLoggedIn = AuthService().isUserLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      title: 'DonorX',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      // initialRoute: "// home",
      // routes: routes,
      // home: FutureBuilder<bool>(
      //     future: _isLoggedIn,
      //     builder: (context, snapshot) {
      //       if (snapshot.connectionState == ConnectionState.waiting) {
      //         return Scaffold(
      //           body: Center(child: CircularProgressIndicator()),
      //         );
      //       }
      //
      //       if (snapshot.data == true) {
      //         return TestingProfile();
      //       } else {
      //         return OnboardingScreen();
      //       }
      //     }),
      debugShowCheckedModeBanner: false,
    );
  }
}
