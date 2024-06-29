import 'package:flutter/material.dart';
import 'workout_form.dart';
import 'workout_list.dart';

class NewWorkoutPage extends StatelessWidget {
  const NewWorkoutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workouts'),
      ),
      body: WorkoutList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WorkoutForm()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}