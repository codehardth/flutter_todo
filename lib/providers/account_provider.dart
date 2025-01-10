import 'dart:io';

import 'package:flutter/material.dart';

import '../services/api_services.dart';

// AccountProvider ที่ใช้ในการจัดการข้อมูลเกี่ยวกับผู้ใช้ เช่น การเข้าสู่ระบบ (login) และการออกจากระบบ (logout) 
class AccountProvider with ChangeNotifier {
  // มีการใช้ ApiServices เพื่อเชื่อมต่อกับ API
  final ApiServices _apiService = ApiServices();

  // _token และ _user: ตัวแปรที่เก็บข้อมูล token และ user หากผู้ใช้ login สำเร็จ
  String? _token;
  String? _user;

  // token และ user: เป็น getter สำหรับดึงข้อมูล token และ user ออกมาใช้ในที่อื่นในแอป
  String? get token => _token;
  String? get user => _user;

  // ฟังก์ชันนี้ใช้เพื่อตรวจสอบว่าผู้ใช้ล็อกอินอยู่หรือไม่ โดยการเช็คว่ามี token หรือไม่
  bool isLoggedIn() => _token != null;

  Future<bool> login(String email, String password) async {
    final response = await _apiService.login(email, password);

    // หาก API ตอบกลับว่าสำเร็จ (statusCode == HttpStatus.ok) 200 ok
    // จะเก็บข้อมูล token และ user
    if (response.statusCode == HttpStatus.ok) {
      _token = response.data["token"];
      _user = response.data["user"];

      _apiService.setAuthToken(token);

      // เรียก notifyListeners() เพื่อแจ้งให้ widget ที่ subscribe อยู่ได้รับรู้
      notifyListeners();
      return true;
    }

    return false;
  }

  Future<bool> logout() async {
    if (_token == null) return false;

    final response = await _apiService.logout(_token!);

    if (response.statusCode == HttpStatus.ok) {
      // หาก logout สำเร็จ จะรีเซ็ตค่า _token และ _user เป็น null
      _token = null;
      _user = null;

      _apiService.setAuthToken(null);

      // เรียก notifyListeners() เพื่อแจ้งให้ widget ที่ subscribe อยู่ได้รับรู้
      notifyListeners();
      return true;
    }

    return false;
  }
}
