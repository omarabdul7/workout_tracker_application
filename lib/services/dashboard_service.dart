import '/models/workout_instance.dart';
import '../enums.dart';
import 'dart:math';

class DashboardService {
  /// Process workout instances into structured data for dashboard
  DashboardResult processWorkoutInstances(List<WorkoutInstance> instances, TimeFrame timeFrame) {
    try {
      // Prepare result object
      final result = DashboardResult();
      
      // Process instances
      Map<DateTime, List<WorkoutInstance>> workoutInstancesByDate = {};
      Map<String, Map<String, num>> volumeByMuscleGroup = {};
      Map<String, Map<String, num>> setsByMuscleGroup = {};
      Map<String, Map<String, double>> oneRepMaxByExercise = {};
      
      // Filter instances based on selected time frame
      final now = DateTime.now();
      final filteredInstances = instances.where((instance) {
        final date = instance.createdAt;
        switch (timeFrame) {
          case TimeFrame.last7Days:
            return now.difference(date).inDays <= 7;
          case TimeFrame.lastMonth:
            return now.difference(date).inDays <= 30;
          case TimeFrame.lastYear:
            return now.difference(date).inDays <= 365;
          default:
            return true;
        }
      }).toList();

      // Calculate yearly workouts (workouts in the current year)
      final currentYear = now.year;
      final yearlyWorkouts = instances.where((instance) => 
        instance.createdAt.year == currentYear
      ).length;
      
      // Group instances by date and process metrics
      for (final instance in filteredInstances) {
        final date = instance.createdAt;
        final dateKey = DateTime(date.year, date.month, date.day);
        workoutInstancesByDate.putIfAbsent(dateKey, () => []).add(instance);

        final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        for (final exercise in instance.exercises) {
          final muscleGroup = exercise.muscleGroup;
          if (muscleGroup != 'unknown') {
            volumeByMuscleGroup
              .putIfAbsent(muscleGroup, () => {})
              .update(dateStr, (value) => value + exercise.totalVolume, ifAbsent: () => exercise.totalVolume);

            setsByMuscleGroup
              .putIfAbsent(muscleGroup, () => {})
              .update(dateStr, (value) => value + exercise.sets.length, ifAbsent: () => exercise.sets.length);
          }

          double maxOneRepMax = 0;
          for (final set in exercise.sets) {
            double oneRepMax = exercise.calculateOneRepMax(set.weight, set.reps);
            if (oneRepMax > maxOneRepMax) {
              maxOneRepMax = oneRepMax;
            }
          }

          oneRepMaxByExercise
            .putIfAbsent(exercise.name, () => {})
            .update(dateStr, (value) => value > maxOneRepMax ? value : maxOneRepMax, ifAbsent: () => maxOneRepMax);
        }
      }

      // Save processed data
      result.workoutInstancesByDate = workoutInstancesByDate;
      result.volumeByMuscleGroup = volumeByMuscleGroup;
      result.setsByMuscleGroup = setsByMuscleGroup;
      result.oneRepMaxByExercise = oneRepMaxByExercise;
      
      // Calculate derived metrics
      result.totalWorkouts = instances.length;
      result.yearlyWorkouts = yearlyWorkouts;
      result.totalVolume = volumeByMuscleGroup.values.fold(
        0.0, 
        (sum, dateMap) => sum + dateMap.values.fold(0.0, (a, b) => a + b.toDouble())
      );
      
      // Calculate workout streak
      calculateWorkoutStreak(instances, result);
      
      // Calculate muscle group totals
      calculateMuscleGroupTotals(volumeByMuscleGroup, result);
      
      // Calculate weekly volume data
      calculateWeeklyVolumeData(workoutInstancesByDate, timeFrame, result);
      
      // Calculate top exercises
      calculateTopExercises(workoutInstancesByDate, oneRepMaxByExercise, result);
      
      return result;
    } catch (e) {
      print('Error processing workout data: $e');
      return DashboardResult()..error = e.toString();
    }
  }
  
  void calculateWorkoutStreak(List<WorkoutInstance> instances, DashboardResult result) {
    if (instances.isEmpty) {
      result.workoutStreak = 0;
      result.lastWorkoutDate = null;
      return;
    }

    try {
      instances.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      result.lastWorkoutDate = instances.first.createdAt;
      
      int streak = 1;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      final workoutDays = <DateTime>{};
      for (final instance in instances) {
        workoutDays.add(DateTime(
          instance.createdAt.year,
          instance.createdAt.month,
          instance.createdAt.day,
        ));
      }
      
      final sortedDays = workoutDays.toList()..sort((a, b) => b.compareTo(a));
      
      if (sortedDays.isEmpty || !sortedDays.contains(today)) {
        final yesterday = today.subtract(const Duration(days: 1));
        if (!workoutDays.contains(yesterday)) {
          streak = 0;
        }
      }
      
      for (int i = 0; i < sortedDays.length - 1; i++) {
        final difference = sortedDays[i].difference(sortedDays[i + 1]).inDays;
        if (difference == 1) {
          streak++;
        } else {
          break;
        }
      }
      
      result.workoutStreak = streak;
    } catch (e) {
      print('Error calculating streak: $e');
      result.workoutStreak = 0;
    }
  }

  void calculateMuscleGroupTotals(
    Map<String, Map<String, num>> volumeByMuscleGroup, 
    DashboardResult result
  ) {
    try {
      Map<String, double> totalsByMuscleGroup = {};
      
      volumeByMuscleGroup.forEach((muscleGroup, dateMap) {
        totalsByMuscleGroup[muscleGroup] = dateMap.values
            .fold(0.0, (total, volume) => total + volume.toDouble());
      });
      
      result.totalsByMuscleGroup = totalsByMuscleGroup;
    } catch (e) {
      print('Error calculating muscle group totals: $e');
      result.totalsByMuscleGroup = {};
    }
  }

  void calculateWeeklyVolumeData(
    Map<DateTime, List<WorkoutInstance>> workoutInstances,
    TimeFrame timeFrame,
    DashboardResult result
  ) {
    try {
      List<MapEntry<DateTime, double>> weeklyVolumeData = [];
      
      // Get dates based on selected time frame
      final now = DateTime.now();
      int numberOfWeeks;
      
      switch (timeFrame) {
        case TimeFrame.last7Days:
          numberOfWeeks = 1;
          break;
        case TimeFrame.lastMonth:
          numberOfWeeks = 4;
          break;
        case TimeFrame.lastYear:
          numberOfWeeks = 12; // Show monthly data for a year
          break;
        default:
          numberOfWeeks = 4;
      }
      
      // Generate date ranges
      List<DateTime> dateBoundaries = [];
      
      if (timeFrame == TimeFrame.lastYear) {
        // For yearly view, show monthly data
        for (int i = 0; i <= numberOfWeeks; i++) {
          dateBoundaries.add(
            DateTime(
              now.year,
              now.month - i,
              1,
            ),
          );
        }
      } else {
        // For weekly view, show weekly data
        for (int i = 0; i <= numberOfWeeks; i++) {
          dateBoundaries.add(
            DateTime(
              now.year,
              now.month,
              now.day - (i * 7),
            ),
          );
        }
      }
      
      // Sort dates in ascending order
      dateBoundaries.sort((a, b) => a.compareTo(b));
      
      // Calculate volume for each period
      for (var i = 0; i < dateBoundaries.length - 1; i++) {
        final startDate = dateBoundaries[i];
        final endDate = dateBoundaries[i + 1];
        
        double periodVolume = 0;
        workoutInstances.forEach((date, instances) {
          if (date.isAfter(startDate) && date.isBefore(endDate) || date.isAtSameMomentAs(startDate)) {
            for (final instance in instances) {
              for (final exercise in instance.exercises) {
                periodVolume += exercise.totalVolume.toDouble();
              }
            }
          }
        });
        
        weeklyVolumeData.add(MapEntry(startDate, periodVolume));
      }
      
      // Ensure there's at least some data to display
      if (weeklyVolumeData.isEmpty) {
        weeklyVolumeData = List.generate(numberOfWeeks, (index) {
          final date = now.subtract(Duration(days: (numberOfWeeks - 1 - index) * 7));
          return MapEntry(date, 0.0);
        });
      }
      
      result.weeklyVolumeData = weeklyVolumeData;
      
      // Calculate week-over-week metrics
      if (weeklyVolumeData.length >= 2) {
        result.thisWeekVolume = weeklyVolumeData.last.value;
        result.lastWeekVolume = weeklyVolumeData[weeklyVolumeData.length - 2].value;
      }
    } catch (e) {
      print('Error calculating weekly volume data: $e');
      // Provide fallback data to prevent UI errors
      final now = DateTime.now();
      result.weeklyVolumeData = List.generate(7, (index) {
        final date = now.subtract(Duration(days: 6 - index));
        return MapEntry(date, 0.0);
      });
    }
  }
  
  void calculateTopExercises(
    Map<DateTime, List<WorkoutInstance>> workoutInstances,
    Map<String, Map<String, double>> oneRepMaxByExercise,
    DashboardResult result
  ) {
    try {
      // Calculate the most common exercises
      final exerciseCounts = <String, int>{};
      
      workoutInstances.forEach((date, instances) {
        for (final instance in instances) {
          for (final exercise in instance.exercises) {
            exerciseCounts.update(
              exercise.name, 
              (count) => count + 1, 
              ifAbsent: () => 1
            );
          }
        }
      });
      
      // Sort and take top 5
      final topExerciseEntries = exerciseCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
        
      result.topExercises = topExerciseEntries
        .take(min(5, topExerciseEntries.length))
        .map((e) => e.key)
        .toList();
        
      // Calculate best one rep max for each exercise
      Map<String, double> bestOneRepMaxByExercise = {};
      
      oneRepMaxByExercise.forEach((exercise, dateMap) {
        bestOneRepMaxByExercise[exercise] = dateMap.values.fold(
          0.0, 
          (max, value) => value > max ? value : max
        );
      });
      
      result.bestOneRepMaxByExercise = bestOneRepMaxByExercise;
    } catch (e) {
      print('Error calculating top exercises: $e');
      result.topExercises = [];
      result.bestOneRepMaxByExercise = {};
    }
  }
}

/// Result object containing all dashboard data
class DashboardResult {
  Map<DateTime, List<WorkoutInstance>> workoutInstancesByDate = {};
  Map<String, Map<String, num>> volumeByMuscleGroup = {};
  Map<String, Map<String, num>> setsByMuscleGroup = {};
  Map<String, Map<String, double>> oneRepMaxByExercise = {};
  Map<String, double> totalsByMuscleGroup = {};
  Map<String, double> bestOneRepMaxByExercise = {};
  
  List<MapEntry<DateTime, double>> weeklyVolumeData = [];
  List<String> topExercises = [];
  
  int workoutStreak = 0;
  DateTime? lastWorkoutDate;
  int totalWorkouts = 0;
  int yearlyWorkouts = 0;
  double totalVolume = 0;
  
  double thisWeekVolume = 0;
  double lastWeekVolume = 0;
  
  String? error;
  
  bool get hasError => error != null;
} 