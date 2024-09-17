import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationUtil {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final FirebaseMessaging _firebaseMessaging;
  final _androidChanel = const AndroidNotificationChannel(
    'channel_id',
    'channel_name',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  NotificationUtil(
      this.flutterLocalNotificationsPlugin, this._firebaseMessaging);

  Future<void> initialize() async {
    await _initializeLocal();

    await _initializeRemote();
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const android = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );
    const ios = DarwinNotificationDetails();
    const platform = NotificationDetails(android: android, iOS: ios);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platform,
      payload: payload,
    );
  }

  Future<void> _initializeRemote() async {
    await _firebaseMessaging.requestPermission();

    await _firebaseMessaging.getToken().then((token) {
      print("Firebase Messaging Token: $token");
    });

    _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Listen for notifications in the background
    FirebaseMessaging.onBackgroundMessage(_messageHandler);

    // Listen for notifications in the foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle when the app is opened via a notification tap
    _firebaseMessaging.getInitialMessage().then((message) {
      if (message != null) {
        _handleNotificationTap(
            message); // Handle notification tap when app is closed
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen(
        _handleNotificationTap); // Handle notification tap when app is in background
  }

  void _handleNotificationTap(RemoteMessage message) {
    // Handle when the notification is tapped and the app is opened
    // Navigate to the desired screen or perform an action

    // final payload = jsonEncode(message.data);
    // navigatorKey.currentState?.pushNamed('/notification', arguments: payload);
  }

// This will handle showing the notification in the foreground
  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    // Show notification only when the app is in the foreground
    showNotification(
      title: notification.title ?? '',
      body: notification.body ?? '',
      payload: jsonEncode(message.data),
    );
  }

  Future<void> _initializeLocal() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);

    await flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        print('Notification Received: ${details.payload}');
      },
    );

    final androidPlatform =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    androidPlatform?.createNotificationChannel(_androidChanel);
  }
}

// Background message handler (Firebase will show the notification for us)
@pragma('vm:entry-point')
Future<void> _messageHandler(RemoteMessage message) async {
  message.notification;
  // Do nothing here if you don’t need to handle background messages directly
  // Firebase handles background notification presentation by default
}
