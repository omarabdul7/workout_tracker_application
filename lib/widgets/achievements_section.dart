import 'package:flutter/material.dart';
import '../models/workout_instance.dart';

class AchievementsSection extends StatelessWidget {
  final List<WorkoutInstance> workouts;
  
  const AchievementsSection({
    Key? key,
    required this.workouts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (workouts.isEmpty) {
      return const SizedBox.shrink();
    }

    // Find personal records
    final Map<String, double> personalRecords = _findPersonalRecords();
    if (personalRecords.isEmpty) {
      return const SizedBox.shrink();
    }

    // Get the top 3 PRs
    final topRecords = personalRecords.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final displayRecords = topRecords.take(3).toList();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.emoji_events,
                  color: Colors.amber,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Personal Records',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: displayRecords.map((record) {
                return _buildAchievementCard(
                  context: context,
                  title: record.key,
                  value: '${record.value.toStringAsFixed(1)} lbs',
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard({
    required BuildContext context,
    required String title,
    required String value,
  }) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: theme.colorScheme.secondary.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.fitness_center,
                color: theme.colorScheme.secondary,
                size: 24,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'One Rep Max',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, double> _findPersonalRecords() {
    final Map<String, double> prByExercise = {};
    
    for (final workout in workouts) {
      for (final exercise in workout.exercises) {
        double maxOneRepMax = 0;
        for (final set in exercise.sets) {
          double oneRepMax = exercise.calculateOneRepMax(set.weight, set.reps);
          if (oneRepMax > maxOneRepMax) {
            maxOneRepMax = oneRepMax;
          }
        }
        
        if (maxOneRepMax > 0) {
          final currentMax = prByExercise[exercise.name] ?? 0;
          if (maxOneRepMax > currentMax) {
            prByExercise[exercise.name] = maxOneRepMax;
          }
        }
      }
    }
    
    return prByExercise;
  }
} 