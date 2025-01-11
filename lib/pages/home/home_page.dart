import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/pages/home/widgets/todo_chart_page.dart';

import '../../../routes/app_routes.dart';
import '../../helpers/snackbar_helper.dart';
import '../../providers/todo_provider.dart';
import 'widgets/dialogs/todo_form_dialog_widget.dart';
import 'widgets/layout_widget_page.dart';
import 'widgets/todo_list_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // _currentIndex: ใช้เก็บค่า index ของหน้าที่ผู้ใช้เลือกใน BottomNavigationBar
  int _currentIndex = 0;

  // กำหนดค่าคงที่แทน index ของแต่ละหน้า
  final int _listPageIndex = 0;
  final int _layoutWidgetPageIndex = 1;
  final int _chartPageIndex = 2;
  final int _chatPageIndex = 3;

  // รายการของ Widget แต่ละหน้า โดยใช้ keyword "late" คือจะมีการกำหนดค่าในภายหลัง
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    // ตรวจสอบสถานะการ login
    getAuthState(context);

    // กำหนด page ที่จะแสดง โดย "chart_page" และ "chat_page" ถูกสร้างโดยเรียกใช้ buildComingSoonPageWidget(icon)
    _pages = [
      const TodoListPage(),
      const LayoutWidgetPage(),
      const TodoChartPage(),
      buildComingSoonPageWidget(icon: Icons.chat),
    ];
  }

  // buildComingSoonPageWidget: ใช้สร้างหน้าชั่วคราวพร้อมข้อความ "Coming soon..." และไอคอนที่กำหนด
  Center buildComingSoonPageWidget({
    required IconData icon,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 100,
            color: Colors.grey,
          ),
          const Text('Coming soon...'),
        ],
      ),
    );
  }

  // แสดง Dialog สำหรับเพิ่ม To-do ใหม่ โดยใช้ TodoFormDialogWidget
  void _showAddTodoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => TodoFormDialogWidget(
        // initial* ใช้สำหรับกำหนดค่าเริ่มต้นให้ todo object
        initialTitle: null,
        initialPriority: null,
        initialStatus: null,
        initialDueDate: null,
        // onSave: callback fucntion เมื่อผู้ใช้กดปุ่มบันทึกที่ TodoFormDialogWidget
        onSave: (
          title,
          priority,
          status,
          dueDate,
        ) async {
          // ใช้ Provider เพื่อสร้าง todo
          final todoProvider = context.read<TodoProvider>();

          await todoProvider.createTodoAsync(
            title: title,
            priority: priority,
            status: status,
            dueDate: dueDate,
          );

          if (context.mounted) {
            showCustomSnackBar(
              context: context,
              message: 'เพิ่มข้อมูลสำเร็จ!',
            );
          }

          // อัปเดตรายการ To-do หลังการบันทึก
          todoProvider.getListAsync();
        },
        // isEdit: ใช้กำหนดว่าเป็น mode edit หรือไม่ (ถ้า false คือ mode add)
        isEdit: false,
      ),
    );
  }

  // return title ของหน้าแต่ละหน้าตาม _currentIndex,
  // หากไม่พบจะ return 'unknow page'
  String getTitleByPageIndex() {
    if (_currentIndex == _listPageIndex) {
      return 'To-do list';
    }

    if (_currentIndex == _layoutWidgetPageIndex) {
      return 'Layout widget example';
    }

    if (_currentIndex == _chartPageIndex) {
      return 'To-do chart';
    }

    if (_currentIndex == _chatPageIndex) {
      return 'Chatroom';
    }

    return 'unknow page';
  }

  // logout ใช้สำหรับ navigate ไปยังหน้า login และลบ auth_token ออกจาก SharedPreferences
  Future<void> logout() async {
    // SharedPreferences ใช้สำหรับบันทึกข้อมูลในรุปแบบ { key, vlaue } เก็บไว้ในอปกรณ์
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('auth_token');

    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  // ตรวจสอบว่าผู้ใช้ล็อกอินหรือยัง โดยดูจาก auth_token
  // ถ้าไม่เจอ token หรือ token ว่าง ให้เรียก logout
  Future<void> getAuthState(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token');

    if (authToken == null || authToken.isEmpty) {
      logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar มี title และปุ่ม logout ที่มุมขวาสุด
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(getTitleByPageIndex()),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              logout();
            },
          ),
        ],
      ),
      // IndexedStack ใช้จัดการหลายๆ page โดยที่แสดงเพียง page เดียวในแต่ละครั้ง
      // โดยที่ไม่ต้องทำลายและสร้าง widget ใหม่ทุกครั้งที่สลับไปมา เพิ่มประสิทธิภาพของ app
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      // FloatingActionButton ใช้ร่วมกับ Visibility เพื่อกำหนดให้แสดงเมื่อหน้า To-do List ถูกเลือกเท่านั้น
      floatingActionButton: Visibility(
        visible: _currentIndex == _listPageIndex,
        child: FloatingActionButton(
          onPressed: () {
            _showAddTodoDialog(context);
          },
          child: const Icon(Icons.add),
        ),
      ),
      // ใช้สำหรับเปลี่ยนหน้า โดยอัปเดต _currentIndex และเรียก setState เพื่ออัปเดต UI
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag),
            label: 'Layout',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Chart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
        ],
      ),
    );
  }
}
