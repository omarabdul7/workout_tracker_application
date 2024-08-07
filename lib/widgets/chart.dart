import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

Widget buildChart(List<MapEntry<String, num>> data, String unit) {
  if (data.isEmpty) {
    return const Center(child: Text('No data available for this time frame'));
  }

  final maxY = data.map((e) => e.value.toDouble()).reduce((max, v) => max > v ? max : v) * 1.2;

  return BarChart(
    BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxY,
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            return BarTooltipItem(
              '${data[group.x].key}\n',
              const TextStyle(color: Colors.white),
              children: <TextSpan>[
                TextSpan(
                  text: '${rod.toY.toStringAsFixed(1)} $unit',
                  style: const TextStyle(
                    color: Colors.yellow,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              if (value.toInt() % (data.length ~/ 7 + 1) != 0) {
                return const SizedBox.shrink();
              }
              if (value.toInt() >= 0 && value.toInt() < data.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Transform.rotate(
                    angle: -0.5,
                    child: Text(
                      data[value.toInt()].key,
                      style: const TextStyle(fontSize: 10),
                    ),
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
            getTitlesWidget: (value, meta) {
              return Text(
                '${value.toInt()} $unit',
                style: const TextStyle(fontSize: 10),
              );
            },
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