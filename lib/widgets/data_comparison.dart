import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../enums.dart';
import 'filter_dropdowns.dart';
import 'data_card.dart';
import 'dart:math';
import '/models/workout_instance.dart';


Widget buildDataComparison(
  BuildContext context,
  ViewType selectedViewType,
  TimeFrame selectedTimeFrame,
  GroupBy selectedGroupBy,
  Map<String, Map<String, num>> volumeByMuscleGroup,
  Map<String, Map<String, num>> setsByMuscleGroup,
  Map<String, Map<String, double>> oneRepMaxByExercise,
  List<WorkoutInstance> workoutInstances,  
  Function(ViewType?) onViewTypeChanged,
  Function(TimeFrame?) onTimeFrameChanged,
  Function(GroupBy?) onGroupByChanged,
) {
  Map<String, Map<String, num>> data;
  String title;

  switch (selectedViewType) {
    case ViewType.volume:
      data = selectedGroupBy == GroupBy.muscleGroup 
        ? volumeByMuscleGroup 
        : convertVolumeToExercise(volumeByMuscleGroup, workoutInstances);
      title = 'Volume';
    case ViewType.sets:
      data = selectedGroupBy == GroupBy.muscleGroup 
        ? setsByMuscleGroup 
        : convertSetsToExercise(setsByMuscleGroup, workoutInstances);
      title = 'Sets';
    case ViewType.oneRepMax:
      data = selectedGroupBy == GroupBy.muscleGroup 
        ? convertOneRepMaxToMuscleGroup(oneRepMaxByExercise) 
        : oneRepMaxByExercise.map((k, v) => MapEntry(k, Map<String, num>.from(v)));
      title = 'One Rep Max';
  }



  title += selectedGroupBy == GroupBy.muscleGroup ? ' by Muscle Group' : ' by Exercise';

  final sortedGroups = data.entries.toList()
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
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 8),
            buildFilterDropdowns(
              selectedViewType,
              selectedTimeFrame,
              selectedGroupBy,
              onViewTypeChanged,
              onTimeFrameChanged,
              onGroupByChanged,
              context
            ),
          ],
        ),
      ),
      ...sortedGroups.map((entry) {
        final group = entry.key;
        final groupData = entry.value;
        final aggregatedData = aggregateData(groupData, selectedTimeFrame);
        final sortedAggregatedData = sortAggregatedData(aggregatedData, selectedTimeFrame);
        final percentageChange = calculatePercentageChange(sortedAggregatedData);

        return buildDataCard(context, group, percentageChange, sortedAggregatedData, selectedViewType);
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

Map<String, num> aggregateData(Map<String, num> data, TimeFrame timeFrame) {
  final now = DateTime.now();
  final aggregatedData = <String, num>{};

  switch (timeFrame) {
    case TimeFrame.last7Days:
      for (int i = 6; i >= 0; i--) {
        final day = now.subtract(Duration(days: i));
        final dayKey = DateFormat('MM-dd').format(day);
        aggregatedData[dayKey] = 0;
      }
      data.forEach((key, value) {
        final date = parseDate(key);
        if (date.isAfter(now.subtract(Duration(days: 7)))) {
          final dayKey = DateFormat('MM-dd').format(date);
          aggregatedData[dayKey] = (aggregatedData[dayKey] ?? 0) + value;
        }
      });

    case TimeFrame.lastMonth:
      for (int i = 29; i >= 0; i--) {
        final day = now.subtract(Duration(days: i));
        final weekNumber = ((30 - i - 1) / 7).floor() + 1;
        final weekKey = 'Week $weekNumber';
        aggregatedData.putIfAbsent(weekKey, () => 0);
      }
      data.forEach((key, value) {
        final date = parseDate(key);
        if (date.isAfter(now.subtract(Duration(days: 30)))) {
          final weekNumber = ((30 - date.difference(now.subtract(Duration(days: 30))).inDays - 1) / 7).floor() + 1;
          final weekKey = 'Week $weekNumber';
          aggregatedData[weekKey] = (aggregatedData[weekKey] ?? 0) + value;
        }
      });

    case TimeFrame.lastYear:
      for (int i = 11; i >= 0; i--) {
        final month = now.subtract(Duration(days: i * 30));
        final monthKey = DateFormat('yyyy-MM').format(month);
        aggregatedData[monthKey] = 0;
      }
      data.forEach((key, value) {
        final date = parseDate(key);
        if (date.isAfter(now.subtract(Duration(days: 365)))) {
          final monthKey = DateFormat('yyyy-MM').format(date);
          aggregatedData[monthKey] = (aggregatedData[monthKey] ?? 0) + value;
        }
      });
  }

  return aggregatedData;
}

List<MapEntry<String, num>> sortAggregatedData(Map<String, num> data, TimeFrame timeFrame) {
  final sortedEntries = data.entries.toList();
  
  switch (timeFrame) {
    case TimeFrame.last7Days:
      sortedEntries.sort((a, b) => DateFormat('MM-dd').parse(a.key).compareTo(DateFormat('MM-dd').parse(b.key)));
    case TimeFrame.lastMonth:
      sortedEntries.sort((a, b) {
        final weekA = int.parse(a.key.split(' ')[1]);
        final weekB = int.parse(b.key.split(' ')[1]);
        return weekA.compareTo(weekB);
      });
    case TimeFrame.lastYear:
      sortedEntries.sort((a, b) => DateFormat('yyyy-MM').parse(a.key).compareTo(DateFormat('yyyy-MM').parse(b.key)));
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

Map<String, Map<String, num>> convertOneRepMaxToMuscleGroup(Map<String, Map<String, double>> oneRepMaxByExercise) {
  Map<String, Map<String, num>> oneRepMaxByMuscleGroup = {};

  oneRepMaxByExercise.forEach((exercise, dateMap) {
    String muscleGroup = ExerciseInstance.exerciseDetails[exercise.toLowerCase()]?['muscleGroup'] ?? 'unknown';
    
    dateMap.forEach((date, oneRepMax) {
      oneRepMaxByMuscleGroup
        .putIfAbsent(muscleGroup, () => {})
        .update(date, (value) => max(value, oneRepMax), ifAbsent: () => oneRepMax);
    });
  });

  return oneRepMaxByMuscleGroup;
}

Map<String, Map<String, num>> convertVolumeToExercise(Map<String, Map<String, num>> volumeByMuscleGroup, List<WorkoutInstance> workoutInstances) {
  Map<String, Map<String, num>> volumeByExercise = {};
  
  for (var workout in workoutInstances) {
    for (var exercise in workout.exercises) {
      String dateStr = DateFormat('yyyy-MM-dd').format(workout.createdAt);
      volumeByExercise
        .putIfAbsent(exercise.name, () => {})
        .update(dateStr, (value) => value + exercise.totalVolume, ifAbsent: () => exercise.totalVolume);
    }
  }
  
  return volumeByExercise;
}

Map<String, Map<String, num>> convertSetsToExercise(Map<String, Map<String, num>> setsByMuscleGroup, List<WorkoutInstance> workoutInstances) {
  Map<String, Map<String, num>> setsByExercise = {};
  
  for (var workout in workoutInstances) {
    for (var exercise in workout.exercises) {
      String dateStr = DateFormat('yyyy-MM-dd').format(workout.createdAt);
      setsByExercise
        .putIfAbsent(exercise.name, () => {})
        .update(dateStr, (value) => value + exercise.sets.length, ifAbsent: () => exercise.sets.length);
    }
  }
  
  return setsByExercise;
}