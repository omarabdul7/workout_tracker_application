import 'package:flutter/material.dart';

class EmptyDashboard extends StatelessWidget {
  final Function onStartWorkout;

  const EmptyDashboard({
    super.key,
    required this.onStartWorkout,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No workouts yet',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking your fitness journey',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => onStartWorkout(),
            icon: const Icon(Icons.fitness_center),
            label: const Text('Start First Workout'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
} 