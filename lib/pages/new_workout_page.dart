import 'package:flutter/material.dart';
import 'New Workout Pages/create_workout_template.dart';
import 'New Workout Pages/workout_template_list.dart';

class NewWorkoutPage extends StatelessWidget {
  const NewWorkoutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: WorkoutTemplateList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateWorkoutTemplate()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}