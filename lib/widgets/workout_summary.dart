import 'package:flutter/material.dart';
import '../models/workout_instance.dart';

class WorkoutSummary extends StatelessWidget {
  final List<WorkoutInstance> workouts;
  
  const WorkoutSummary({Key? key, required this.workouts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (workouts.isEmpty) {
      return _buildEmptyState(context);
    }

    final totalWorkouts = workouts.length;
    final totalVolume = _calculateTotalVolume();
    final totalSets = _calculateTotalSets();
    
    return Card(
      margin: const EdgeInsets.all(0),
      elevation: 0,
      color: theme.colorScheme.onPrimary.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.onPrimary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Workout Summary',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  context: context,
                  icon: Icons.fitness_center,
                  value: totalWorkouts.toString(),
                  label: 'Workouts',
                ),
                _buildSummaryItem(
                  context: context,
                  icon: Icons.monitor_weight_outlined,
                  value: '${totalVolume.toStringAsFixed(0)}',
                  label: 'Total Volume',
                ),
                _buildSummaryItem(
                  context: context,
                  icon: Icons.repeat,
                  value: totalSets.toString(),
                  label: 'Total Sets',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.all(0),
      elevation: 0,
      color: theme.colorScheme.onPrimary.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.onPrimary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.onPrimary.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.fitness_center_outlined,
                size: 48,
                color: theme.colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No workouts yet',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start your fitness journey today',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimary.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required BuildContext context,
    required IconData icon,
    required String value,
    required String label,
  }) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: theme.colorScheme.onPrimary.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onPrimary.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  double _calculateTotalVolume() {
    double totalVolume = 0;
    
    for (final workout in workouts) {
      for (final exercise in workout.exercises) {
        totalVolume += exercise.totalVolume;
      }
    }
    
    return totalVolume;
  }

  int _calculateTotalSets() {
    int totalSets = 0;
    
    for (final workout in workouts) {
      for (final exercise in workout.exercises) {
        totalSets += exercise.sets.length;
      }
    }
    
    return totalSets;
  }
} 