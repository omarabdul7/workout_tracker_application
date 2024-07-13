import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '/models/workout_instance.dart';
import '/services/workout_instance_service.dart';
import 'History Pages/historic_workouts.dart';
import 'package:table_calendar/table_calendar.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  Future<List<WorkoutInstance>>? _historicWorkoutsFuture;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<WorkoutInstance>> _workoutInstances = {};

  @override
  void initState() {
    super.initState();
    _historicWorkoutsFuture = WorkoutInstanceService().getHistoricWorkouts();
    _historicWorkoutsFuture?.then((workouts) {
      setState(() {
        _workoutInstances = groupWorkoutsByDay(workouts);
      });
    });
  }

  String formatDateTime(DateTime dateTime) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd h:mma');
    return formatter.format(dateTime);
  }

  Map<DateTime, List<WorkoutInstance>> groupWorkoutsByDay(List<WorkoutInstance> workouts) {
    Map<DateTime, List<WorkoutInstance>> groupedWorkouts = {};

    for (var workout in workouts) {
      DateTime workoutDay = DateTime(workout.createdAt.year, workout.createdAt.month, workout.createdAt.day);
      if (!groupedWorkouts.containsKey(workoutDay)) {
        groupedWorkouts[workoutDay] = [];
      }
      groupedWorkouts[workoutDay]!.add(workout);
    }

    return groupedWorkouts;
  }

  Map<String, List<WorkoutInstance>> groupWorkoutsByYearMonth(List<WorkoutInstance> workouts) {
    Map<String, List<WorkoutInstance>> groupedWorkouts = {};

    for (var workout in workouts) {
      String yearMonth = DateFormat('yyyy MMMM').format(workout.createdAt);
      if (!groupedWorkouts.containsKey(yearMonth)) {
        groupedWorkouts[yearMonth] = [];
      }
      groupedWorkouts[yearMonth]!.add(workout);
    }

    return groupedWorkouts;
  }

 Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      onFormatChanged: (format) {
        if (_calendarFormat != format) {
          setState(() {
            _calendarFormat = format;
          });
        }
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
      eventLoader: (day) {
        final eventDay = DateTime(day.year, day.month, day.day);
        return _workoutInstances[eventDay] ?? [];
      },
    );
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue,
      ),
      width: 16.0,
      height: 16.0,
      child: Center(
        child: Text(
          '${events.length}',
          style: TextStyle().copyWith(
            color: Colors.white,
            fontSize: 12.0,
          ),
        ),
      ),
    );
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
            Map<String, List<WorkoutInstance>> groupedWorkouts = groupWorkoutsByYearMonth(workouts);

            return Column(
              children: [
                _buildCalendar(),
                Expanded(
                  child: ListView.builder(
                    itemCount: groupedWorkouts.keys.length,
                    itemBuilder: (context, index) {
                      String yearMonth = groupedWorkouts.keys.elementAt(index);
                      List<WorkoutInstance> workoutsInMonth = groupedWorkouts[yearMonth]!;

                      return ExpansionTile(
                        title: Text(yearMonth),
                        children: workoutsInMonth.map((workout) {
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
                        }).toList(),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
