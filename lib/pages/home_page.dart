import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '/services/workout_instance_service.dart';
import '/models/workout_instance.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

enum TimeFrame { week, month, year }
enum ViewType { volume, sets }

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Map<DateTime, List<WorkoutInstance>> _workoutInstances = {};
  final Map<String, Map<String, double>> _volumeByMuscleGroup = {};
  final Map<String, Map<String, int>> _setsByMuscleGroup = {};
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  TimeFrame _selectedTimeFrame = TimeFrame.month;
  ViewType _selectedViewType = ViewType.volume;
  
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
    _setsByMuscleGroup.clear();

    for (final instance in instances) {
      final date = instance.createdAt;
      final dateKey = DateTime(date.year, date.month, date.day);
      _workoutInstances.putIfAbsent(dateKey, () => []).add(instance);

      final monthWeekKey = _getMonthWeekKey(date);
      for (final exercise in instance.exercises) {
        final muscleGroup = exercise.muscleGroup;
        if (muscleGroup != 'unknown') {
          _volumeByMuscleGroup
            .putIfAbsent(muscleGroup, () => {})
            .update(monthWeekKey, (value) => value + exercise.totalVolume, ifAbsent: () => exercise.totalVolume);
          
          _setsByMuscleGroup
            .putIfAbsent(muscleGroup, () => {})
            .update(monthWeekKey, (value) => value + exercise.sets.length, ifAbsent: () => exercise.sets.length);
        }
      }
    }
  }

  String _getMonthWeekKey(DateTime date) {
    final monthName = DateFormat('MMMM').format(date);
    final weekNumber = ((date.day - 1) / 7).floor() + 1;
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
          _buildMuscleGroupComparison(),
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

Widget _buildMuscleGroupComparison() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column( 
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _selectedViewType == ViewType.volume
                  ? 'Volume by Muscle Group'
                  : 'Sets by Muscle Group',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8), 
            Row(
              children: [
                DropdownButton<ViewType>(
                  value: _selectedViewType,
                  onChanged: (ViewType? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedViewType = newValue;
                      });
                    }
                  },
                  items: ViewType.values.map((ViewType viewType) {
                    return DropdownMenuItem<ViewType>(
                      value: viewType,
                      child: Text(viewType.toString().split('.').last.capitalize()),
                    );
                  }).toList(),
                ),
                const SizedBox(width: 16),
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
          ],
        ),
      ),
      ..._buildMuscleGroupCards(),
    ],
  );
}


List<Widget> _buildMuscleGroupCards() {
  final data = _selectedViewType == ViewType.volume
      ? _volumeByMuscleGroup
      : _setsByMuscleGroup;

  final sortedMuscleGroups = data.entries.toList()
    ..sort((a, b) {
      double sumA = a.value.values.fold(0.0, (sum, element) => sum + element.toDouble());
      double sumB = b.value.values.fold(0.0, (sum, element) => sum + element.toDouble());
      return sumB.compareTo(sumA);
    });

  return sortedMuscleGroups.map((entry) {
    final muscleGroup = entry.key;
    final muscleData = entry.value;
    final aggregatedData = _aggregateData(muscleData, _selectedTimeFrame);
    final sortedAggregatedData = aggregatedData.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final total = aggregatedData.values.reduce((sum, element) => sum + element);

    return Card(
      color: const Color.fromARGB(255, 241, 246, 249),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ExpansionTile(
        title: Text(
          '$muscleGroup - Total: ${_selectedViewType == ViewType.volume ? '${total.toStringAsFixed(2)} lbs' : '${total.toInt()} sets'}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              height: 200,
              child: _buildChart(sortedAggregatedData),
            ),
          ),
          ..._buildDataList(sortedAggregatedData),
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
          final value = entry.value.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: value,
                color: Colors.lightBlue,
                width: 20,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  List<Widget> _buildDataList(List<MapEntry<String, double>> sortedAggregatedData) {
    return sortedAggregatedData.map((entry) {
      return ListTile(
        title: Text(
          '${entry.key}: ${_selectedViewType == ViewType.volume ? '${entry.value.toStringAsFixed(2)} lbs' : '${entry.value.toInt()} sets'}',
        ),
      );
    }).toList();
  }

  Map<String, double> _aggregateData(Map<String, dynamic> data, TimeFrame timeFrame) {
    final result = <String, double>{};

    data.forEach((key, value) {
      final parts = key.split(' ');
      final month = parts[0];
      final weekNumber = int.parse(parts[2]);
      final year = int.parse(parts[3]);

      if (timeFrame == TimeFrame.week) {
        final weekKey = 'Week $weekNumber of $month';
        result.update(weekKey, (v) => v + value.toDouble(), ifAbsent: () => value.toDouble());
      } else if (timeFrame == TimeFrame.month) {
        result.update(month, (v) => v + value.toDouble(), ifAbsent: () => value.toDouble());
      } else if (timeFrame == TimeFrame.year) {
        result.update(year.toString(), (v) => v + value.toDouble(), ifAbsent: () => value.toDouble());
      }
    });

    return result;
  }

  String _getShortLabel(String label) {
    if (label.startsWith('Week')) {
      final parts = label.split(' ');
      return 'W${parts[1]}';
    } else if (label.length == 4 && int.tryParse(label) != null) {
      return label;
    }
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