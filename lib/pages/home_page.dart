import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '/services/workout_instance_service.dart';
import '/models/workout_instance.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

enum TimeFrame { week, month, year }

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Map<DateTime, List<WorkoutInstance>> _workoutInstances = {};
  final Map<String, Map<String, double>> _volumeByMuscleGroup = {};
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  TimeFrame _selectedTimeFrame = TimeFrame.week;
  
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchWorkoutData();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _fetchWorkoutData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final instances = await WorkoutInstanceService().getHistoricWorkouts();
      _processWorkoutInstances(instances);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching workout data: $e');
      setState(() {
        _isLoading = false;
        _error = 'Failed to load workout data. Please try again.';
      });
    }
    _refreshController.refreshCompleted();
  }

  void _processWorkoutInstances(List<WorkoutInstance> instances) {
    _workoutInstances.clear();
    _volumeByMuscleGroup.clear();

    for (final instance in instances) {
      final date = DateTime(instance.createdAt.year, instance.createdAt.month, instance.createdAt.day);
      _workoutInstances.putIfAbsent(date, () => []).add(instance);

      final monthWeekKey = _getMonthWeekKey(date);
      for (final exercise in instance.exercises) {
        final muscleGroup = exercise.muscleGroup;
        _volumeByMuscleGroup
          .putIfAbsent(muscleGroup, () => {})
          .update(monthWeekKey, (value) => value + exercise.totalVolume, ifAbsent: () => exercise.totalVolume);
      }
    }
  }

  String _getMonthWeekKey(DateTime date) {
    final monthName = DateFormat('MMMM').format(date);
    final weekNumber = (date.day - 1) ~/ 7 + 1;
    return '$monthName Week $weekNumber ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: _fetchWorkoutData,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!, style: Theme.of(context).textTheme.bodyLarge));
    }
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildCalendar(),
          const SizedBox(height: 20),
          _buildVolumeComparison(),
        ],
      ),
    );
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

  Widget _buildVolumeComparison() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Padding(
          padding: const EdgeInsets.all(16.0),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Volume by Muscle Group',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              DropdownButton<TimeFrame>(
                value: _selectedTimeFrame,
                onChanged: (TimeFrame? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedTimeFrame = newValue;
                    });
                  }
                },
                items: TimeFrame.values.map((TimeFrame timeFrame) {
                  return DropdownMenuItem<TimeFrame>(
                    value: timeFrame,
                    child: Text(timeFrame.toString().split('.').last.capitalize()),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        ..._buildMuscleGroupCards(),
      ],
    );
  }

  List<Widget> _buildMuscleGroupCards() {
    final sortedMuscleGroups = _volumeByMuscleGroup.entries.toList()
      ..sort((a, b) => b.value.values.reduce((sum, element) => sum + element)
          .compareTo(a.value.values.reduce((sum, element) => sum + element)));

    return sortedMuscleGroups.map((entry) {
      final muscleGroup = entry.key;
      final volumeData = entry.value;
      final aggregatedData = _aggregateData(volumeData, _selectedTimeFrame);
      final sortedAggregatedData = aggregatedData.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));

      final totalVolume = aggregatedData.values.reduce((sum, element) => sum + element);

      return Card(
        color: const Color.fromARGB(255, 241, 246, 249),
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: ExpansionTile(
          title: Text('$muscleGroup - Total: ${totalVolume.toStringAsFixed(2)} lbs',
              style: Theme.of(context).textTheme.titleMedium),
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                height: 200,
                child: _buildChart(sortedAggregatedData),
              ),
            ),
            ..._buildVolumeList(sortedAggregatedData),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildChart(List<MapEntry<String, double>> data) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: data.map((e) => e.value).reduce((max, v) => max > v ? max : v) * 1.2,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < data.length) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _getShortLabel(data[value.toInt()].key),
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              reservedSize: 40,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
        barGroups: data.asMap().entries.map((entry) {
          final index = entry.key;
          final volume = entry.value.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: volume,
                color: Colors.lightBlue,
                width: 20,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  List<Widget> _buildVolumeList(List<MapEntry<String, double>> sortedAggregatedData) {
    return sortedAggregatedData.map((entry) {
      return ListTile(
        title: Text('${entry.key}: ${entry.value.toStringAsFixed(2)} lbs'),
      );
    }).toList();
  }

  Map<String, double> _aggregateData(Map<String, double> data, TimeFrame timeFrame) {
    final result = <String, double>{};

    data.forEach((key, value) {
      final parts = key.split(' ');
      final month = parts[0];
      final weekOrYear = parts[1];
      final year = parts[2];

      if (timeFrame == TimeFrame.week && weekOrYear.startsWith('Week')) {
        final weekNumber = int.tryParse(weekOrYear.replaceFirst('Week', '').trim()) ?? 0;
        final weekKey = 'Week $weekNumber';
        result.update(weekKey, (v) => v + value, ifAbsent: () => value);
      } else if (timeFrame == TimeFrame.month) {
        result.update(month, (v) => v + value, ifAbsent: () => value);
      } else if (timeFrame == TimeFrame.year) {
        result.update('Year $year', (v) => v + value, ifAbsent: () => value);
      }
    });

    return result;
  }

  String _getShortLabel(String label) {
    return label.split(' ').map((word) => word[0]).join('');
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) {
      return this;
    }
    return this[0].toUpperCase() + substring(1);
  }
}
