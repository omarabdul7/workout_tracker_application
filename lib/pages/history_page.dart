import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '/models/workout_instance.dart';
import '/services/workout_instance_service.dart';
import 'History Pages/historic_workouts.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  Future<List<WorkoutInstance>>? _historicWorkoutsFuture;

  @override
  void initState() {
    super.initState();
    _historicWorkoutsFuture = WorkoutInstanceService().getHistoricWorkouts();
  }

  String formatDateTime(DateTime dateTime) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd h:mma');
    return formatter.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
      ),
      body: FutureBuilder<List<WorkoutInstance>>(
        future: _historicWorkoutsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No workouts found.'));
          } else {
            List<WorkoutInstance> workouts = snapshot.data!;
            return ListView.builder(
              itemCount: workouts.length,
              itemBuilder: (context, index) {
                WorkoutInstance workout = workouts[index];
                return ListTile(
                  title: Text(workout.name),
                  subtitle: Text(formatDateTime(workout.createdAt)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HistoricWorkout(workoutInstance: workout),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
