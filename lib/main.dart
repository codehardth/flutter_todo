import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/todo_provider.dart';
import 'routes/route.dart';
import 'services/firebase_notification_service.dart';

// Handler สำหรับ Background Message
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("*** 🟢Background message received: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // เรียกใช้งาน FirebaseNotificationService
  FirebaseNotificationService().initialize();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
    // MultiProvider: ใช้สำหรับให้บริการหลายๆ Provider ในแอปเดียวกัน
    MultiProvider(
      providers: [
        // มีการใช้ ChangeNotifierProvider ซึ่งจะเป็นการบอกให้แอปสามารถเข้าถึงข้อมูลหรือสถานะจาก Provider ได้
        ChangeNotifierProvider(create: (_) => TodoProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // theme: กำหนดธีมของแอปเพื่อเลือกสีพื้นฐาน (ในที่นี้คือสีเขียว)
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      // onGenerateRoute: ใช้เพื่อจัดการการนำทางระหว่างหน้าจอ ตามชื่อของหน้าจอ
      onGenerateRoute: Routes.generateRoute,
      // initialRoute: กำหนดว่าเมื่อแอปเปิดขึ้นมาครั้งแรกจะให้ไปที่หน้าไหน
      initialRoute: Routes.initialRoute,
      // debugShowCheckedModeBanner: ตั้งค่าให้ไม่แสดงแบนเนอร์ที่บอกว่าแอปอยู่ในโหมด debug
      debugShowCheckedModeBanner: false,
    );
  }
}
