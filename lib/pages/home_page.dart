import 'package:flutter/material.dart';
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
  final Map<String, Map<String, num>> _volumeByMuscleGroup = {};
  final Map<String, Map<String, num>> _setsByMuscleGroup = {};
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  TimeFrame _selectedTimeFrame = TimeFrame.month;
  ViewType _selectedViewType = ViewType.volume;

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
          const SizedBox(height: 20),
          _buildMuscleGroupComparison(),
        ],
      ),
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
        final aggregatedDataA = _aggregateData(a.value, _selectedTimeFrame);
        final aggregatedDataB = _aggregateData(b.value, _selectedTimeFrame);
        double sumA = _calculateTotal(aggregatedDataA);
        double sumB = _calculateTotal(aggregatedDataB);
        return sumB.compareTo(sumA);
      });

    return sortedMuscleGroups.map((entry) {
      final muscleGroup = entry.key;
      final muscleData = entry.value;
      final aggregatedData = _aggregateData(muscleData, _selectedTimeFrame);
      final sortedAggregatedData = aggregatedData.entries.toList()
        ..sort((a, b) => _parseDate(a.key).compareTo(_parseDate(b.key)));

      final percentageChange = _calculatePercentageChange(sortedAggregatedData);

      return Card(
        color: const Color.fromARGB(255, 241, 246, 249),
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: ExpansionTile(
          title: Text(
            muscleGroup,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          subtitle: Text(
            _formatPercentageChange(percentageChange),
            style: TextStyle(
              color: percentageChange >= 0 ? Colors.green : Colors.red,
            ),
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

  Widget _buildChart(List<MapEntry<String, num>> data) {
    if (data.isEmpty) {
      return const Center(child: Text('No data available for this time frame'));
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: data.map((e) => e.value.toDouble()).reduce((max, v) => max > v ? max : v) * 1.2,
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
                toY: value.toDouble(),
                color: Colors.lightBlueAccent,
                width: 16,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  String _getShortLabel(String label) {
    final parts = label.split(' ');
    if (parts.length >= 2) {
      return '${parts[0]} ${parts[1]}';
    }
    return label;
  }

  double _calculateTotal(Map<String, num> data) {
    return data.values.fold(0.0, (sum, value) => sum + value);
  }

  DateTime _parseDate(String dateStr) {
    final parts = dateStr.split(' ');
    if (parts.length == 4) {
      final month = DateFormat.MMMM().parse(parts[0]).month;
      final week = int.parse(parts[2]);
      final year = int.parse(parts[3]);
      // Calculate the first day of the given week in the month
      final firstDayOfMonth = DateTime(year, month, 1);
      final daysToAdd = (week - 1) * 7 - firstDayOfMonth.weekday + 1;
      return firstDayOfMonth.add(Duration(days: daysToAdd));
    }
    return DateTime.now(); // Default to current date if parsing fails
  }

  DateTime _getCutoffDate(DateTime now, TimeFrame timeFrame) {
    switch (timeFrame) {
      case TimeFrame.week:
        return now.subtract(const Duration(days: 7));
      case TimeFrame.month:
        return DateTime(now.year, now.month - 1, now.day);
      case TimeFrame.year:
        return DateTime(now.year - 1, now.month, now.day);
    }
  }

  Map<String, num> _aggregateData(Map<String, num> data, TimeFrame timeFrame) {
    final now = DateTime.now();
    final cutoffDate = _getCutoffDate(now, timeFrame);

    return Map.fromEntries(data.entries.where((entry) {
      final entryDate = _parseDate(entry.key);
      switch (timeFrame) {
        case TimeFrame.week:
          return entryDate.isAfter(cutoffDate);
        case TimeFrame.month:
          return entryDate.year == now.year && entryDate.month == now.month;
        case TimeFrame.year:
          return entryDate.year == now.year;
      }
    }));
  }

  double _calculatePercentageChange(List<MapEntry<String, num>> sortedData) {
    if (sortedData.length >= 2) {
      final latestValue = sortedData.last.value.toDouble();
      final previousValue = sortedData[sortedData.length - 2].value.toDouble();

      if (previousValue != 0) {
        return ((latestValue - previousValue) / previousValue) * 100;
      }
    }
    return 0.0;
  }

  String _formatPercentageChange(double percentageChange) {
    return '${percentageChange >= 0 ? '+' : ''}${percentageChange.toStringAsFixed(2)}%';
  }

  List<Widget> _buildDataList(List<MapEntry<String, num>> data) {
    return data.map((entry) {
      final label = entry.key;
      final value = entry.value;
      return ListTile(
        title: Text(label),
        trailing: Text(value.toString()),
      );
    }).toList();
  }
}

extension StringExtension on String {
  String capitalize() {
    return this[0].toUpperCase() + substring(1);
  }
} 