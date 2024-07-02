import 'package:flutter/material.dart';
import '/models/workout.dart';
import '/services/workout_service.dart';
import 'new_workout_instance_page.dart';

class WorkoutTemplateList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Workouts'),
      ),
      body: StreamBuilder<List<Workout>>(
        stream: WorkoutService().getWorkouts(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: snapshot.data!.map((workout) => ListTile(
              title: Text(workout.name),
              subtitle: Text('${workout.exercises.length} exercises'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewWorkoutInstancePage(workout: workout),
                  ),
                );
              },
            )).toList(),
          );
        },
      ),
    );
  }
}
