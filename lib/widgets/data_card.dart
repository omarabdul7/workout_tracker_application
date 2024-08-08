import 'package:flutter/material.dart';
import 'chart.dart';
import 'data_list.dart';
import '../enums.dart';

Widget buildDataCard(
  BuildContext context,
  String groupName,
  double percentageChange,
  List<MapEntry<String, num>> sortedAggregatedData,
  ViewType selectedViewType,
) {
  final theme = Theme.of(context);
  final isDarkMode = theme.brightness == Brightness.dark;
  final textColor = isDarkMode ? Colors.white : Colors.black;

  final lightCardColor = const Color.fromARGB(255, 241, 246, 249);
  final darkCardColor = Colors.grey[800]; 

  return Card(
    color: isDarkMode ? darkCardColor : lightCardColor,
    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    child: ExpansionTile(
      title: Text(
        groupName,
        style: theme.textTheme.titleMedium?.copyWith(color: textColor),
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
            child: buildChart(sortedAggregatedData, getUnit(selectedViewType)),
          ),
        ),
        ...buildDataList(sortedAggregatedData, getUnit(selectedViewType)),
      ],
    ),
  );
}

String formatPercentageChange(double percentageChange) {
  if (percentageChange.isInfinite) {
    return percentageChange > 0 ? 'N/A' : 'N/A';
  }
  return '${percentageChange >= 0 ? '+' : ''}${percentageChange.toStringAsFixed(2)}%';
}

String getUnit(ViewType viewType) {
  switch (viewType) {
    case ViewType.volume:
      return 'lbs';
    case ViewType.sets:
      return 'sets';
    case ViewType.oneRepMax:
      return 'lbs';
  }
}