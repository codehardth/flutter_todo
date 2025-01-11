import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../models/bar_chart_model.dart';
import 'chart_data_not_found_widget.dart';

class TodoBarChartWidget extends StatelessWidget {
  const TodoBarChartWidget({super.key});

  Color _getBarColor(double dataCount) {
    if (dataCount > 25) return Colors.blue;
    if (dataCount > 20) return Colors.blue[400]!;
    if (dataCount > 15) return Colors.blue[300]!;
    if (dataCount > 10) return Colors.blue[200]!;

    return Colors.blue[100]!;
  }

  List<BarChartGroupData> _createBarGroups(List<BarChartModel> data) {
    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final barData = entry.value;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: barData.value,
            color: _getBarColor(barData.value),
            width: 20,
            borderRadius: BorderRadius.circular(5),
          ),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<BarChartModel> data = [
      BarChartModel(label: 'Jan', value: 10),
      BarChartModel(label: 'Feb', value: 20),
      BarChartModel(label: 'Mar', value: 30),
      BarChartModel(label: 'Apr', value: 25),
      BarChartModel(label: 'May', value: 15),
    ];

    return Column(
      children: [
        Text(
          "Todo Count by Month",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        data.isEmpty
            ? const ChartDataNotFoundWidget(icon: Icons.bar_chart)
            : SizedBox(
                height: MediaQuery.of(context).size.width * 0.6,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    barGroups: _createBarGroups(data),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.green),
                    ),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (
                            double value,
                            TitleMeta meta,
                          ) {
                            final index = value.toInt();

                            if (index < data.length) {
                              return Text(data[index].label);
                            }

                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      ],
    );
  }
}
