import 'package:flutter/material.dart';
import 'package:todo_app/pages/home/widgets/charts/todo_bar_chart_widget.dart';

import 'charts/todo_pie_chart_widget.dart';

class TodoChartPage extends StatefulWidget {
  const TodoChartPage({super.key});

  @override
  State<TodoChartPage> createState() => _TodoChartPageState();
}

class _TodoChartPageState extends State<TodoChartPage> {
  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 25),
          TodoPieChartWidget(),
          SizedBox(height: 25),
          TodoBarChartWidget(),
        ],
      ),
    );
  }
}
