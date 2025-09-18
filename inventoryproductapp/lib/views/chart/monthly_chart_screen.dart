import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MonthlySalesChartScreen extends StatelessWidget {
  final Map<String, double> monthlySales;

  const MonthlySalesChartScreen({super.key, required this.monthlySales});

  @override
  Widget build(BuildContext context) {
    final entries = monthlySales.entries.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Monthly Sales Chart"),
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: (monthlySales.values.reduce((a, b) => a > b ? a : b)) * 1.2,
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    int index = value.toInt();
                    if (index >= entries.length) return const SizedBox.shrink();
                    return Text(entries[index].key,
                        style: const TextStyle(fontSize: 10));
                  },
                  interval: 1,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1000,
                  getTitlesWidget: (value, meta) {
                    return Text("₹${value.toInt()}",
                        style: const TextStyle(fontSize: 10));
                  },
                ),
              ),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            barGroups: entries
                .asMap()
                .map((i, e) => MapEntry(
              i,
              BarChartGroupData(x: i, barRods: [
                BarChartRodData(
                    toY: e.value,
                    color: Colors.green.shade700,
                    width: 18,
                    borderRadius: BorderRadius.circular(4)),
              ]),
            ))
                .values
                .toList(),
          ),
        ),
      ),
    );
  }
}