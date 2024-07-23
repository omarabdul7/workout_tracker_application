import 'package:flutter/material.dart';
import 'chart.dart';
import 'data_list.dart';

Widget buildMuscleGroupCard(BuildContext context, String muscleGroup, double percentageChange, List<MapEntry<String, num>> sortedAggregatedData) {
  return Card(
    color: const Color.fromARGB(255, 241, 246, 249),
    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    child: ExpansionTile(
      title: Text(
        muscleGroup,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text(
        formatPercentageChange(percentageChange),
        style: TextStyle(
          color: percentageChange >= 0 ? Colors.green : Colors.red,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            height: 200,
            child: buildChart(sortedAggregatedData),
          ),
        ),
        ...buildDataList(sortedAggregatedData),
      ],
    ),
  );
}

String formatPercentageChange(double percentageChange) {
  if (percentageChange.isInfinite) {
    return percentageChange > 0 ? '+∞%' : '-∞%';
  }
  return '${percentageChange >= 0 ? '+' : ''}${percentageChange.toStringAsFixed(2)}%';
}