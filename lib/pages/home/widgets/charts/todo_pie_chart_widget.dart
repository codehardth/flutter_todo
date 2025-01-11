import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../models/todo_model.dart';
import '../../../../providers/todo_provider.dart';
import 'chart_data_not_found_widget.dart';

class TodoPieChartWidget extends StatelessWidget {
  const TodoPieChartWidget({super.key});

  Map<String, int> _calculatePriorityCounts(List<TodoModel> todos) {
    final Map<String, int> counts = {
      ToDoPriority.low: 0,
      ToDoPriority.medium: 0,
      ToDoPriority.high: 0,
    };

    for (var todo in todos) {
      counts[todo.priority] = counts[todo.priority]! + 1;
    }

    return counts;
  }

  List<PieChartSectionData> _getTaskPrioritySections(List<TodoModel> todos) {
    final priorityCounts = _calculatePriorityCounts(todos);
    final totalTotal = priorityCounts.values.reduce((a, b) => a + b);
    final priorityColors = {
      ToDoPriority.high: Colors.red,
      ToDoPriority.medium: Colors.orange,
      ToDoPriority.low: Colors.green,
    };

    return priorityCounts.entries.map((entry) {
      final priority = entry.key;
      final count = entry.value;
      final percentage = totalTotal > 0 ? (count / totalTotal) * 100 : 0;

      return PieChartSectionData(
        color: priorityColors[priority],
        value: count.toDouble(),
        title: "$priority\n${percentage.toStringAsFixed(2)}%",
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final todos = Provider.of<TodoProvider>(
      context,
      listen: true,
    ).todos;

    return Column(
      children: [
        Text(
          "Todo Priority Distribution",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        todos.isEmpty
            ? const ChartDataNotFoundWidget(icon: Icons.pie_chart)
            : SizedBox(
                height: MediaQuery.of(context).size.width * 0.6,
                child: PieChart(
                  PieChartData(
                    sections: _getTaskPrioritySections(todos),
                    centerSpaceRadius: 50,
                    sectionsSpace: 5,
                  ),
                ),
              ),
      ],
    );
  }
}
