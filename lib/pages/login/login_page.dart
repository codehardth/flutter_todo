import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../routes/app_routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // ตัวแปร _usernameController และ _passwordController ถูกสร้างขึ้นเพื่อควบคุมข้อมูลที่ผู้ใช้กรอกใน TextField สำหรับ Username และ Password
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> login() async {
    // ใช้ SharedPreferences.getInstance() เพื่อเข้าถึงพื้นที่จัดเก็บข้อมูลในเครื่อง
    final prefs = await SharedPreferences.getInstance();

    // เก็บค่า auth_token ที่ใช้ในการยืนยันตัวตนของผู้ใช้
    prefs.setString('auth_token', 'auth_token_result');

    // หากฟังก์ชันนี้ถูกเรียกในขณะที่หน้าจอยังแสดงอยู่ (ตรวจสอบด้วย mounted) มันจะเปลี่ยนหน้าไปยัง homePage โดยใช้ Navigator.pushReplacementNamed()
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.homePage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar: เป็นแถบด้านบนของหน้าจอ ซึ่งมีชื่อหน้าจอว่า "Login"
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Login'),
      ),
      // SingleChildScrollView: ใช้สำหรับทำให้หน้าจอสามารถเลื่อนขึ้นลงได้ เมื่อมีคอนเทนต์ที่ยาวเกินขนาดหน้าจอ
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Column(
                  children: [
                    Icon(
                      Icons.task,
                      size: 150,
                      color: Colors.green,
                    ),
                    Text(
                      'Todo',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                maxLength: 100,
                maxLines: 1,
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                maxLength: 100,
                maxLines: 1,
                obscureText: true,
              ),
              const SizedBox(height: 20),
              // เป็นปุ่มสำหรับล็อกอิน โดยจะทำการตรวจสอบก่อนว่าผู้ใช้กรอกข้อมูล Username และ Password หรือยัง (หากไม่กรอกจะไม่ทำการล็อกอิน)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 40),
                ),
                onPressed: () {
                  {
                    if (_usernameController.text.isNotEmpty &&
                        _passwordController.text.isNotEmpty) {
                      login();
                    }
                  }
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
