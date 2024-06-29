import 'package:flutter/material.dart';
import 'workout_form.dart';

class NewWorkoutPage extends StatelessWidget {
  const NewWorkoutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Workout'),
      ),
      body: const WorkoutForm(),
    );
  }
}
