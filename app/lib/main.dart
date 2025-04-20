import 'package:app/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'package:app/core/network/dio_client.dart';
import 'package:app/core/storage/secure_storage.dart';
import 'package:app/router.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('🔙 Background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await NotificationService.init();
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  GetIt.instance.registerSingleton<SecureStorage>(SecureStorage());
  GetIt.instance.registerSingleton<DioClient>(DioClient());
  runApp(const BloodApp());
}

class BloodApp extends StatefulWidget {
  const BloodApp({super.key});

  @override
  _BloodAppState createState() => _BloodAppState();
}

class _BloodAppState extends State<BloodApp> {
  @override
  void initState() {
    super.initState();
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
      debugShowCheckedModeBanner: false,
    );
  }
}
