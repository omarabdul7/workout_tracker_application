import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/models/workout_instance.dart';
import '/services/workout_instance_service.dart';

class HistoricWorkout extends StatelessWidget {
  final WorkoutInstance workoutInstance;

  const HistoricWorkout({Key? key, required this.workoutInstance}) : super(key: key);

  String formatDateTime(DateTime dateTime) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd h:mma');
    return formatter.format(dateTime);
  }

  Future<void> _deleteWorkout(BuildContext context) async {
    final service = WorkoutInstanceService();

    try {
      await service.deleteWorkoutInstance(workoutInstance.name, workoutInstance.createdAt);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workout deleted successfully')),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      print('Error deleting workout instance: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error deleting workout instance')),
        );
      }
    }
  }

void _showDeleteConfirmationDialog(BuildContext context) {
  final theme = Theme.of(context);
  
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: theme.cardTheme.color,
        title: Text(
          'Delete Workout',
          style: theme.textTheme.headlineMedium,
        ),
        content: Text(
          'Are you sure you want to delete this workout?',
          style: theme.textTheme.bodyLarge,
        ),
        actions: [
          TextButton(
            child: Text(
              'Cancel',
              style: TextStyle(color: theme.colorScheme.onPrimary),
            ),
            onPressed: () {
              Navigator.of(context).pop(); 
            },
          ),
          TextButton(
            child: Text(
              'Delete',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            onPressed: () {
              Navigator.of(context).pop(); 
              _deleteWorkout(context); 
            },
          ),
        ],
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(workoutInstance.name),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmationDialog(context),
          ),
        ],
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
