import 'package:flutter/material.dart';
import 'New Workout Pages/create_workout_template.dart';
import 'New Workout Pages/workout_template_list.dart';

class NewWorkoutPage extends StatelessWidget {
  const NewWorkoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: WorkoutTemplateList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateWorkoutTemplate()),
          );
        },
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }
}