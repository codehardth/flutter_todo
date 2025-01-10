import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../models/todo_model.dart';
import '../../../../providers/todo_provider.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  Future<void> _showEditTodoDialog(
    BuildContext context,
    String todoId,
  ) async {
    final todoProvider = context.read<TodoProvider>();

    final todo = await todoProvider.getByIdAsync(todoId: todoId);

    if (todo == null) {
      return;
    }

    if (mounted) {
      //🚀🚀🚀***Exercise 1.edit todo with showDialog (isEdit:true)

      // showDialog(
      //   context: context,
      //   builder: (context) => TodoFormDialogWidget(
      //     initialTitle: todo.title,
      // ...
    }
  }

  Future<void> getListAsync() async {
    final todoProvider = context.read<TodoProvider>();

    await todoProvider.getListAsync();

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    getListAsync();
  }

  @override
  Widget build(BuildContext context) {
    final todos = Provider.of<TodoProvider>(context).todos;

    const priorityOrder = ToDoPriority.allStatuses;

    todos.sort((a, b) {
      final priorityComparison = priorityOrder.indexOf(a.priority).compareTo(
            priorityOrder.indexOf(b.priority),
          );

      if (priorityComparison == 0) {
        return a.title.compareTo(b.title);
      }

      return priorityComparison;
    });

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

    return RefreshIndicator(
      onRefresh: () => getListAsync(),
      child: ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) {
          final todo = todos[index];

          return Card(
            child: Slidable(
              endActionPane: ActionPane(
                extentRatio: 0.25,
                motion: const DrawerMotion(),
                children: [
                  SlidableAction(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                    autoClose: true,
                    onPressed: (context) {
                      //🚀🚀🚀***Exercise 2.Remove todo by todoId
                    },
                    backgroundColor: Colors.red[300]!,
                    icon: Icons.delete,
                  ),
                ],
              ),
              child: GestureDetector(
                onLongPress: () {
                  _showEditTodoDialog(
                    context,
                    todo.id,
                  );
                },
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
                      buildBadgeColor(
                        title: 'status',
                        label: todo.status,
                        color: getStatusColor(todo.status),
                        width: 100,
                      ),
                      const SizedBox(height: 5),
                      buildBadgeColor(
                          title: 'prioriry',
                          label: todo.priority,
                          color: getPriorityColor(todo.priority),
                          width: 70),
                      const SizedBox(height: 5),
                      Text(
                          'due date: ${DateFormat('dd-MMM-yyyy').format(todo.dueDate)}'),
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
