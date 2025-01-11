import 'dart:io';

import 'package:flutter/material.dart';
import '../models/todo_model.dart';
import '../services/api_services.dart';

// TodoProvider ใช้จัดการข้อมูล todo
//    - การดึงข้อมูลรายการงานทั้งหมด,
//    - การดึงข้อมูลงานตาม ID,
//    - การสร้าง
//    - การแก้ไข
// รวมถึงการแจ้งการเปลี่ยนแปลงไปยัง UI โดยใช้ notifyListeners()
// ซึ่งเป็นฟีเจอร์หลักของ Provider สำหรับการอัปเดต UI เมื่อข้อมูลมีการเปลี่ยนแปลง
class TodoProvider with ChangeNotifier {
  final _apiService = ApiServices();

  List<TodoModel> _todos = [];

  List<TodoModel> get todos => _todos;

  Future<void> getListAsync() async {
    var res = await _apiService.getTodoListAsync();

    if (res.statusCode != HttpStatus.ok) {
      _todos = [];
      return;
    }

    // หากการดึงข้อมูลสำเร็จ, จะทำการแปลง JSON เป็นออบเจ็กต์ List<TodoModel> และส่งคืน
    _todos =
        (res.data as List).map((item) => TodoModel.fromJson(item)).toList();

    notifyListeners();
  }

  Future<TodoModel?> getByIdAsync({
    required String todoId,
  }) async {
    var res = await _apiService.getTodoByIdAsync(todoId: todoId);

    if (res.statusCode != HttpStatus.ok) {
      return null;
    }

    // หากการดึงข้อมูลสำเร็จ, จะทำการแปลง JSON เป็นออบเจ็กต์ TodoModel และส่งคืน
    return TodoModel.fromJson(res.data);
  }

  Future<String?> createTodoAsync({
    required String title,
    required String priority,
    required String status,
    required DateTime dueDate,
  }) async {
    var res = await _apiService.createTodoAsync(
      title: title,
      priority: priority,
      status: status,
      dueDate: dueDate,
    );

    if (res.statusCode != HttpStatus.created) {
      return null;
    }

    // หากสร้าง todo สำเร็จ, จะส่งคืน id ใหม่ที่สร้าง
    return res.data['id'];
  }

  Future<bool> updateTodoAsync({
    required String id,
    required String title,
    required String priority,
    required String status,
    required DateTime dueDate,
  }) async {
    var res = await _apiService.updateTodoAsync(
      id: id,
      title: title,
      priority: priority,
      status: status,
      dueDate: dueDate,
    );

    if (res.statusCode != HttpStatus.noContent) {
      return false;
    }

    return true;
  }

  Future<bool> deleteTodoByIdAsync({
    required String todoId,
  }) async {
    var res = await _apiService.deleteTodoByIdAsync(todoId: todoId);

    if (res.statusCode != HttpStatus.ok) {
      // หากลบข้อมูลไม่สำเร็จ, จะคืนค่า false
      return false;
    }

    // หากลบข้อมูลสำเร็จ, จะคืนค่า true
    return true;
  }
}
