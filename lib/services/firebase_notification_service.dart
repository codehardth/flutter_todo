import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseNotificationService {
  static final FirebaseNotificationService _instance =
      FirebaseNotificationService._internal();

  factory FirebaseNotificationService() => _instance;

  FirebaseNotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // ขอสิทธิ์ Notification
    await _requestNotificationPermission();

    // ตั้งค่า Local Notifications
    await _setupLocalNotifications();

    // ตั้งค่าการจัดการข้อความใน Background
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

    // ตั้งค่าการจัดการข้อความใน Foreground
    FirebaseMessaging.onMessage.listen(_onMessageHandler);

    // ตั้งค่าการจัดการข้อความเมื่อเปิดแอปจาก Notification
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedAppHandler);

    // จัดการการแจ้งเตือนในสถานะ Terminate
    _handleInitialMessage();

    // ดึง FCM Token
    String? token = await _firebaseMessaging.getToken();
    print("*** 🟢FCM Token: $token");
  }

  Future<void> _requestNotificationPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('*** 🟢User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('*** 🟢User granted provisional permission');
    } else {
      print('*** 🟢User denied permission');
    }
  }

  Future<void> _setupLocalNotifications() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitializationSettings);

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> _backgroundMessageHandler(RemoteMessage message) async {
    print("*** 🟢Handling background message: ${message.messageId}");
    // เพิ่มการจัดการข้อความใน Background (ถ้าจำเป็น)
  }

  void _onMessageHandler(RemoteMessage message) {
    print(
        '*** 🟢Message received in Foreground: ${message.notification?.title}');
    _showLocalNotification(message);
  }

  void _onMessageOpenedAppHandler(RemoteMessage message) {
    print('*** 🟢Notification clicked: ${message.data}');
    // ดำเนินการ เช่น นำผู้ใช้ไปยังหน้าที่ต้องการ
  }

  Future<void> _handleInitialMessage() async {
    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();

    if (initialMessage != null) {
      print('*** 🟢App opened from terminated state: ${initialMessage.data}');
      // จัดการการเปิดแอปจาก Notification ขณะที่แอปอยู่ในสถานะ Terminate
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;

    if (notification != null) {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'default_channel_id',
        'Default Channel',
        importance: Importance.high,
        priority: Priority.high,
      );

      const NotificationDetails notificationDetails =
          NotificationDetails(android: androidDetails);

      await _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        notificationDetails,
      );
    }
  }

  // Subscribe หัวข้อ
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('*** 🟢Subscribed to topic: $topic');
    } catch (e) {
      print('*** 🟢Error subscribing to topic: $e');
    }
  }

  // Unsubscribe หัวข้อ
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('*** 🟢Unsubscribed from topic: $topic');
    } catch (e) {
      print('*** 🟢Error unsubscribing from topic: $e');
    }
  }
}
