import 'package:flutter/material.dart';
import '/models/workout.dart';
import '/services/workout_service.dart';

class WorkoutList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Workout>>(
      stream: WorkoutService().getWorkouts(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        return ListView(
          children: snapshot.data!.map((workout) => ListTile(
            title: Text(workout.name),
            subtitle: Text('${workout.exercises.length} exercises'),
          )).toList(),
        );
      },
    );
  }
}