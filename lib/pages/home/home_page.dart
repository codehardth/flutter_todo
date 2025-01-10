import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../routes/app_routes.dart';
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
  int _currentIndex = 0;
  final int _listPageIndex = 0;
  final int _layoutWidgetPageIndex = 1;
  final int _chartPageIndex = 2;
  final int _chatPageIndex = 3;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    getAuthState(context);

    _pages = [
      const TodoListPage(),
      const LayoutWidgetPage(),
      buildComingSoonPageWidget(icon: Icons.bar_chart),
      buildComingSoonPageWidget(icon: Icons.chat),
    ];
  }

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

  void _showAddTodoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => TodoFormDialogWidget(
        initialTitle: null,
        initialPriority: null,
        initialStatus: null,
        initialDueDate: null,
        onSave: (
          title,
          priority,
          status,
          dueDate,
        ) async {
          final todoProvider = context.read<TodoProvider>();

          await todoProvider.createTodoAsync(
            title: title,
            priority: priority,
            status: status,
            dueDate: dueDate,
          );

          todoProvider.getListAsync();
        },
        isEdit: false,
      ),
    );
  }

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

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('auth_token');

    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

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
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      floatingActionButton: Visibility(
        visible: _currentIndex == _listPageIndex,
        child: FloatingActionButton(
          onPressed: () {
            _showAddTodoDialog(context);
          },
          child: const Icon(Icons.add),
        ),
      ),
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
