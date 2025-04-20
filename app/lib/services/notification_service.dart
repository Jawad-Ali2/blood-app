import 'package:app/core/storage/secure_storage.dart';
import 'package:app/utils/blood_topics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';

class NotificationService {
  static final _firebaseMessaging = FirebaseMessaging.instance;
  static final _storage = GetIt.instance.get<SecureStorage>();
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> subscribeToBloodGroup(String bloodGroup) async {
    final topic = bloodGroupToTopic(bloodGroup);
    await _firebaseMessaging.subscribeToTopic(topic);
    print('Subscribed to topic: $topic');
  }

  static Future<void> init() async {
    // Request permissions (for Android 13+ and iOS)
    await _firebaseMessaging.requestPermission();

    // Android notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // same as in AndroidManifest
      'High Importance Notifications',
      importance: Importance.high,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Retrieve user ID from secure storage
    final user = await _storage.getUser();
    final myId = user?.id;

    // Foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final requesterId = message.data['requesterId'];

      print('📬 Foreground message received: ${message.notification?.title}');
      // if (requesterId != myId) { // Use retrieved user ID here
        final notification = message.notification;
        if (notification != null && message.notification?.android != null) {
          _flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                icon: '@mipmap/ic_launcher',
              ),
            ),
          );
        }
      // }
    });

    // Token logging (for debugging)
    final token = await _firebaseMessaging.getToken();
    print('📲 FCM Token: $token');
  }
}

