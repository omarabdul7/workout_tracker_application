import 'package:flutter/material.dart';
import '../enums.dart' as app_enums;
import 'package:intl/intl.dart';
import 'filter_dropdowns.dart';
import 'muscle_group_card.dart';

Widget buildMuscleGroupComparison(
  BuildContext context,
  app_enums.ViewType selectedViewType,
  app_enums.TimeFrame selectedTimeFrame,
  Map<String, Map<String, num>> volumeByMuscleGroup,
  Map<String, Map<String, num>> setsByMuscleGroup,
  Function(app_enums.ViewType?) onViewTypeChanged,
  Function(app_enums.TimeFrame?) onTimeFrameChanged,
) {
  final data = selectedViewType == app_enums.ViewType.volume
      ? volumeByMuscleGroup
      : setsByMuscleGroup;

  final sortedMuscleGroups = data.entries.toList()
    ..sort((a, b) {
      final aggregatedDataA = aggregateData(a.value, selectedTimeFrame);
      final aggregatedDataB = aggregateData(b.value, selectedTimeFrame);
      double sumA = calculateTotal(aggregatedDataA);
      double sumB = calculateTotal(aggregatedDataB);
      return sumB.compareTo(sumA);
    });

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              selectedViewType == app_enums.ViewType.volume
                  ? 'Volume by Muscle Group'
                  : 'Sets by Muscle Group',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            buildFilterDropdowns(
              selectedViewType,
              selectedTimeFrame,
              onViewTypeChanged,
              onTimeFrameChanged,
            ),
          ],
        ),
      ),
      ...sortedMuscleGroups.map((entry) {
        final muscleGroup = entry.key;
        final muscleData = entry.value;
        final aggregatedData = aggregateData(muscleData, selectedTimeFrame);
        final sortedAggregatedData = sortAggregatedData(aggregatedData, selectedTimeFrame);
        final percentageChange = calculatePercentageChange(sortedAggregatedData);

        return buildMuscleGroupCard(context, muscleGroup, percentageChange, sortedAggregatedData);
      }).toList(),
    ],
  );
}

double calculateTotal(Map<String, num> data) {
  return data.values.fold(0.0, (sum, value) => sum + value);
}

DateTime parseDate(String dateStr) {
  return DateTime.parse(dateStr);
}

Map<String, num> aggregateData(Map<String, num> data, app_enums.TimeFrame timeFrame) {
  final now = DateTime.now();
  final aggregatedData = <String, num>{};

  switch (timeFrame) {
    case app_enums.TimeFrame.week:
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      for (int i = 0; i < 7; i++) {
        final day = startOfWeek.add(Duration(days: i));
        final dayKey = DateFormat('E').format(day);
        aggregatedData[dayKey] = 0;
      }
      data.forEach((key, value) {
        final date = parseDate(key);
        if (date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
            date.isBefore(startOfWeek.add(const Duration(days: 7)))) {
          final dayKey = DateFormat('E').format(date);
          aggregatedData[dayKey] = (aggregatedData[dayKey] ?? 0) + value;
        }
      });

    case app_enums.TimeFrame.month:
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      for (int i = 0; i < (daysInMonth / 7).ceil(); i++) {
        aggregatedData['Week ${i + 1}'] = 0;
      }
      data.forEach((key, value) {
        final date = parseDate(key);
        if (date.year == now.year && date.month == now.month) {
          final weekNumber = ((date.day - 1) / 7).floor() + 1;
          final weekKey = 'Week $weekNumber';
          aggregatedData[weekKey] = (aggregatedData[weekKey] ?? 0) + value;
        }
      });

    case app_enums.TimeFrame.year:
      for (int i = 1; i <= 12; i++) {
        aggregatedData[DateFormat('MMM').format(DateTime(now.year, i))] = 0;
      }
      data.forEach((key, value) {
        final date = parseDate(key);
        if (date.year == now.year) {
          final monthKey = DateFormat('MMM').format(date);
          aggregatedData[monthKey] = (aggregatedData[monthKey] ?? 0) + value;
        }
      });
  }

  return aggregatedData;
}

List<MapEntry<String, num>> sortAggregatedData(Map<String, num> data, app_enums.TimeFrame timeFrame) {
  final sortedEntries = data.entries.toList();
  
  switch (timeFrame) {
    case app_enums.TimeFrame.week:
      final weekDayOrder = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      sortedEntries.sort((a, b) => weekDayOrder.indexOf(a.key).compareTo(weekDayOrder.indexOf(b.key)));    case app_enums.TimeFrame.month:
      sortedEntries.sort((a, b) {
        final weekA = int.parse(a.key.split(' ')[1]);
        final weekB = int.parse(b.key.split(' ')[1]);
        return weekA.compareTo(weekB);
      });
    case app_enums.TimeFrame.year:
      final monthOrder = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      sortedEntries.sort((a, b) => monthOrder.indexOf(a.key).compareTo(monthOrder.indexOf(b.key)));
  }
  return sortedEntries;
}

double calculatePercentageChange(List<MapEntry<String, num>> sortedData) {
  if (sortedData.length < 2) return 0.0;

  final nonZeroEntries = sortedData.where((entry) => entry.value != 0).toList();
  
  if (nonZeroEntries.isEmpty) return 0.0;
  
  if (nonZeroEntries.length == 1) {
    return nonZeroEntries.first.value > 0 ? double.infinity : -100.0;
  }

  final firstValue = nonZeroEntries.first.value.toDouble();
  final lastValue = nonZeroEntries.last.value.toDouble();

  return ((lastValue - firstValue) / firstValue) * 100;
}