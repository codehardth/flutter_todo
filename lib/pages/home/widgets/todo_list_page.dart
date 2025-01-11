import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../models/todo_model.dart';
import '../../../../providers/todo_provider.dart';
import 'dialogs/todo_form_dialog_widget.dart';

// StatefulWidget สำหรับรายการ To-Do List โดยดึงข้อมูลจาก TodoProvider
// ใช้แพ็คเกจต่าง ๆ เช่น
//    - provider สำหรับการจัดการ state,
//    - flutter_slidable สำหรับการเลื่อนการ์ดเพื่อลบรายการ,
//    - และ intl สำหรับจัดการรูปแบบวันที่
class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  // _showEditTodoDialog ใช้แสดง Dialog สำหรับแก้ไขข้อมูลของ To-Do
  Future<void> _showEditTodoDialog(
    BuildContext context,
    String todoId,
  ) async {
    // ใช้ todoProvider.getByIdAsync เพื่อดึงข้อมูล To-Do ตาม todoId
    final todoProvider = context.read<TodoProvider>();

    final todo = await todoProvider.getByIdAsync(todoId: todoId);

    if (todo == null) {
      return;
    }

    // mounted == true: แปลว่า Widget ถูกสร้างและยังอยู่ใน tree (พร้อมแสดงผลและรับการเปลี่ยนแปลง)
    // if (mounted): ใช้เพื่อให้แน่ใจว่า Widget ยังคงอยู่ใน tree ก่อนที่จะเรียกใช้โค้ดที่เกี่ยวข้องกับการเปลี่ยนแปลง state (setState)
    // เมื่อ Widget ถูกลบออกจาก widget tree (เช่น หน้าจอถูกปิดหรือเปลี่ยนไปหน้าอื่น) ค่าของ mounted จะเปลี่ยนเป็น false
    // หากเราเรียก setState ใน Widget ที่ถูกถอดออกจาก tree แล้ว จะเกิด error "setState() called after dispose()"
    if (context.mounted) {
      //🚀🚀🚀***Exercise 1.edit todo with showDialog (isEdit:true)
      showDialog(
        context: context,
        builder: (context) => TodoFormDialogWidget(
          initialTitle: todo.title,
          initialPriority: todo.priority,
          initialStatus: todo.status,
          initialDueDate: todo.dueDate,
          onSave: (
            title,
            priority,
            status,
            dueDate,
          ) async {
            await todoProvider.updateTodoAsync(
              id: todoId,
              title: title,
              priority: priority,
              status: status,
              dueDate: dueDate,
            );

            todoProvider.getListAsync();
          },
          isEdit: true,
        ),
      );
    }
  }

  Future<void> getListAsync() async {
    // ดึงข้อมูลรายการทั้งหมดจาก TodoProvider และอัพเดต state
    final todoProvider = context.read<TodoProvider>();

    await todoProvider.getListAsync();

    if (mounted) {
      // ใช้ setState เพื่ออัพเดต UI หลังจากข้อมูล todo ถูกดึงมาแล้ว
      setState(() {});
    }
  }

  Future<void> deleteTodoByIdAsync({
    required String todoId,
  }) async {
    final todoProvider = context.read<TodoProvider>();

    await todoProvider.deleteTodoByIdAsync(todoId: todoId);

    getListAsync();
  }

  @override
  void initState() {
    super.initState();

    // เรียกดูข้อมูล todo list เป็นอันดับแรก
    getListAsync();
  }

  @override
  Widget build(BuildContext context) {
    final todos = Provider.of<TodoProvider>(context).todos;

    const priorityOrder = ToDoPriority.allStatuses;

    // เรียงลำดับ todo ตามระดับความสำคัญ (priority) ก่อน และชื่อ (title) เป็นลำดับถัดมา
    todos.sort((a, b) {
      final priorityComparison = priorityOrder.indexOf(a.priority).compareTo(
            priorityOrder.indexOf(b.priority),
          );

      if (priorityComparison == 0) {
        return a.title.compareTo(b.title);
      }

      return priorityComparison;
    });

    // ฟังก์ชันสำหรับกำหนดสีให้แต่ละระดับความสำคัญของ todo
    Color getPriorityColor(String priority) {
      switch (priority) {
        case ToDoPriority.high:
          return Colors.red[300]!;
        case ToDoPriority.medium:
          return Colors.orange[300]!;
        case ToDoPriority.low:
          return Colors.green[300]!;
      }

      return Colors.grey;
    }

    // ฟังก์ชันสำหรับกำหนดสีให้แต่ละสถานะของ todo
    Color getStatusColor(String status) {
      switch (status) {
        case ToDoStatus.pending:
          return Colors.grey[300]!;
        case ToDoStatus.inprogress:
          return Colors.blue[300]!;
        case ToDoStatus.completed:
          return Colors.green[300]!;
      }

      return Colors.grey;
    }

    // ฟังก์ชันสำหรับสร้าง badge color
    Row buildBadgeColor({
      required String title,
      required String label,
      required Color color,
      required double width,
    }) {
      return Row(
        children: [
          Text(
            '$title: ',
          ),
          SizedBox(
            width: width,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.all(
                  Radius.circular(15),
                ),
              ),
              child: Align(
                alignment: Alignment.center,
                child: Text(label),
              ),
            ),
          ),
        ],
      );
    }

    // RefreshIndiactor Widget: ใช้สำหรับดึงรายการใหม่เมื่อผู้ใช้ลากหน้าจอลงมา (onRefresh)
    return RefreshIndicator(
      onRefresh: () => getListAsync(),
      child: ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) {
          final todo = todos[index];

          // Card widget: แสดงผลในรูปแบบการ์ดสีเหลืยม
          return Card(
            // Slidable: ใช้สำหรับแสดงปุ่มลบ เมื่อผู้ใช้เลื่อน Card ไปด้านซ้าย
            child: Slidable(
              // ActionPane: ส่วนของ UI ที่จะแสดงเมื่อผู้ใช้เลื่อน Card ไปด้านซ้าย
              endActionPane: ActionPane(
                extentRatio: 0.25,
                motion: const DrawerMotion(),
                children: [
                  // SlidableAction: ใช้สำหรับกำหนดการทำงานของ Sliable
                  SlidableAction(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                    autoClose: true,
                    onPressed: (context) {
                      //🚀🚀🚀***Exercise 2.Remove todo by todoId
                      deleteTodoByIdAsync(todoId: todo.id);
                    },
                    backgroundColor: Colors.red[300]!,
                    icon: Icons.delete,
                  ),
                ],
              ),
              // GestureDetector: ใช้สำหรับ detect เมื่อผู้ใช้มี interact กับ ListTile Widget
              // รองรับหลายรูปแบบท่าทาง เช่น กด, กดค้าง, กด 2 ครั้งติด, การลาก, การซูม ฯลฯ
              child: GestureDetector(
                onLongPress: () {
                  _showEditTodoDialog(
                    context,
                    todo.id,
                  );
                },
                // ListTile: คือ widget สำหรับแสดงข้อมูลที่มีหลายองค์ประกอบ เช่น ส่วนหัว ส่วน title, subTitle, ส่วนท้าย ฯลฯ
                child: ListTile(
                  leading: const Icon(
                    Icons.task,
                    color: Colors.grey,
                  ),
                  title: Text(
                    todo.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // เรียก buildBadgeColor เพื่อส้าง status widget
                      buildBadgeColor(
                        title: 'status',
                        label: todo.status,
                        color: getStatusColor(todo.status),
                        width: 100,
                      ),
                      const SizedBox(height: 5),
                      // เรียก buildBadgeColor เพื่อส้าง priority widget
                      buildBadgeColor(
                          title: 'prioriry',
                          label: todo.priority,
                          color: getPriorityColor(todo.priority),
                          width: 70),
                      const SizedBox(height: 5),
                      // ใช้ package intl เพื่อสร้างฟอร์แมตรูปแบบวันที่ เช่น dd-MMM-yyyy
                      Text(
                          'due date: ${DateFormat('dd-MMM-yyyy').format(todo.dueDate.toLocal())}'),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
