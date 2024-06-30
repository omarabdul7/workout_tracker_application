import 'package:flutter/material.dart';
import '/models/workout.dart';

class WorkoutDetailPage extends StatelessWidget {
  final Workout workout;

  const WorkoutDetailPage({Key? key, required this.workout}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(workout.name),
      ),
      body: ListView(
        children: [
          Divider(),
          ...workout.exercises.map((exercise) => ListTile(
            title: Text(exercise.name),
            trailing: Text('${exercise.sets} sets'),
          )),
        ],
      ),
    );
  }
}