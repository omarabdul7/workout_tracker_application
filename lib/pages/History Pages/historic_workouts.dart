import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/models/workout_instance.dart';

class HistoricWorkout extends StatelessWidget {
  final WorkoutInstance workoutInstance;

  const HistoricWorkout({Key? key, required this.workoutInstance}) : super(key: key);

  String formatDateTime(DateTime dateTime) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd h:mma');
    return formatter.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(workoutInstance.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workoutInstance.name,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Date: ${formatDateTime(workoutInstance.createdAt)}',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 16),
                ...workoutInstance.exercises.map((exercise) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      ...exercise.sets.map((set) {
                        return Text(
                          'Set ${set.setNumber}: ${set.weight} lbs x ${set.reps} reps',
                          style: TextStyle(fontSize: 16),
                        );
                      }).toList(),
                      SizedBox(height: 16),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
