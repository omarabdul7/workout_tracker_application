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
    _loadWorkouts();
  }

  void _loadWorkouts() {
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


Widget _buildCalendar(BuildContext context) {
  final theme = Theme.of(context);

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
    calendarStyle: CalendarStyle(
      todayDecoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.4),
        shape: BoxShape.circle,
      ),
      selectedDecoration: BoxDecoration(
        color: theme.colorScheme.primary,
        shape: BoxShape.circle,
      ),
      weekendTextStyle: TextStyle(color: theme.colorScheme.secondary),
      defaultTextStyle: TextStyle(color: theme.textTheme.bodyLarge!.color),
      outsideTextStyle: TextStyle(color: theme.textTheme.bodyMedium!.color!.withOpacity(0.6)),
      disabledTextStyle: TextStyle(color: theme.disabledColor),
    ),
    headerStyle: HeaderStyle(
      titleTextStyle: theme.textTheme.headlineMedium!,
      formatButtonTextStyle: TextStyle(color: theme.colorScheme.onSurface),
      formatButtonDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
      ),
      leftChevronIcon: Icon(Icons.chevron_left, color: theme.iconTheme.color),
      rightChevronIcon: Icon(Icons.chevron_right, color: theme.iconTheme.color),
    ),
    daysOfWeekStyle: DaysOfWeekStyle(
      weekdayStyle: TextStyle(color: theme.textTheme.bodySmall!.color),
      weekendStyle: TextStyle(color: theme.colorScheme.secondary),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: FutureBuilder<List<WorkoutInstance>>(
        future: _historicWorkoutsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No workouts found.'));
          } else {
            List<WorkoutInstance> workouts = snapshot.data!;
            Map<String, List<WorkoutInstance>> groupedWorkouts = groupWorkoutsByYearMonth(workouts);

            return Column(
              children: [
                _buildCalendar(context),
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
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HistoricWorkout(workoutInstance: workout),
                                ),
                              );
                              _loadWorkouts(); 
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
