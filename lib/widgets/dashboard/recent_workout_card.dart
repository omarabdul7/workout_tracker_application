import 'package:flutter/material.dart';
import 'dart:math';
import '/models/workout_instance.dart';

class RecentWorkoutCard extends StatelessWidget {
  final DateTime? lastWorkoutDate;
  final WorkoutInstance? lastWorkout;
  final Function onViewDetails;

  const RecentWorkoutCard({
    super.key,
    required this.lastWorkoutDate,
    required this.lastWorkout,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    if (lastWorkout == null) {
      return const SizedBox.shrink();
    }
    
    try {
      // Count exercises and total volume
      final exerciseCount = lastWorkout!.exercises.length;
      final workoutVolume = lastWorkout!.exercises.fold(
        0.0, 
        (sum, exercise) => sum + exercise.totalVolume.toDouble()
      );
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Latest Workout',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    _formatDate(lastWorkoutDate!),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '$exerciseCount exercises · ${workoutVolume.toStringAsFixed(0)} lbs',
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Details',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  onTap: () => onViewDetails(),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      for (int i = 0; i < min(3, lastWorkout!.exercises.length); i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  lastWorkout!.exercises[i].name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '${lastWorkout!.exercises[i].sets.length} sets',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (lastWorkout!.exercises.length > 3)
                        Text(
                          'and ${lastWorkout!.exercises.length - 3} more...',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } catch (e) {
      print('Error building recent workout card: $e');
      return const SizedBox.shrink();
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);
    
    if (dateToCheck == today) return 'Today';
    if (dateToCheck == yesterday) return 'Yesterday';
    return '${date.month}/${date.day}/${date.year}';
  }
} 