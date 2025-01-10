import 'package:dio/dio.dart';

class TokenInterceptor extends Interceptor {
  // ใช้สำหรับเก็บค่า token ที่จะใช้ในการยืนยันตัวตน (Authorization)
  String? _token;

  // ใช้กำหนดค่า token เพื่อใช้ในการส่งคำขอที่ต้องการยืนยันตัวตน
  void setToken(String? token) {
    _token = token;
  }

  // เรียกใช้งานเมื่อมีการส่งคำขอออกไปยัง API
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    // ตรวจสอบว่า requiresToken (ที่เก็บใน options.extra) มีค่าเป็น true หรือไม่ (ค่าเริ่มต้นคือ true)
    final bool requiresToken = options.extra["requiresToken"] ?? true;

    // หากต้องใช้ token (requiresToken == true) และ token ไม่เป็น null:
    if (requiresToken && _token != null) {
      // เพิ่ม Authorization header โดยใช้รูปแบบ: Bearer <token>
      options.headers["Authorization"] = "Bearer $_token";
    }

    //ส่งคำขอต่อไปยัง handler (super.onRequest(options, handler))
    super.onRequest(options, handler);
  }

  // ใช้จัดการข้อผิดพลาดที่เกิดขึ้นเมื่อเรียก API
  // @override
  // void onError(
  //   DioException err,
  //   ErrorInterceptorHandler handler,
  // ) async {

  //   // ตรวจสอบว่า HTTP status code เป็น unauthorized (401) หรือไม่
  //   // หาก token หมดอายุ (401)
  //   // ลบ token ที่เก็บไว้ใน SharedPreferences
  //   // นำผู้ใช้กลับไปที่หน้า Login โดยใช้ navigatorKey เพื่อสลับไปที่ route ของ Login (AppRoutes.login)
  //   if (err.response?.statusCode == HttpStatus.unauthorized) {
  //     final prefs = await SharedPreferences.getInstance();
  //     await prefs.remove('token');

  //     navigatorKey.currentState?.pushReplacementNamed(AppRoutes.login);
  //     return;
  //   }

  //   // หลังจากจัดการข้อผิดพลาดแล้วเรียก super.onError(err, handler) เพื่อส่งข้อผิดพลาดต่อไป
  //   super.onError(err, handler);
  // }
}
