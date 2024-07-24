import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

Widget buildChart(List<MapEntry<String, num>> data, String unit) {
  if (data.isEmpty) {
    return const Center(child: Text('No data available for this time frame'));
  }

  return BarChart(
    BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: data.map((e) => e.value.toDouble()).reduce((max, v) => max > v ? max : v) * 1.2,
      barTouchData: BarTouchData(enabled: false),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= 0 && value.toInt() < data.length) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    data[value.toInt()].key,
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
            reservedSize: 40,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) => Text(
              '${value.toInt()} $unit',
              style: const TextStyle(fontSize: 10),
            ),
          ),
        ),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: FlGridData(show: true),
      borderData: FlBorderData(show: false),
      barGroups: data.asMap().entries.map((entry) {
        final index = entry.key;
        final value = entry.value.value;
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: value.toDouble(),
              color: Colors.lightBlueAccent,
              width: 16,
            ),
          ],
        );
      }).toList(),
    ),
  );
}