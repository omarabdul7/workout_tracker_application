import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '/services/workout_instance_service.dart';
import '/models/workout_instance.dart';

enum TimeFrame { week, month, year }
enum ViewType { volume, sets }

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  final WorkoutInstanceService _workoutService = WorkoutInstanceService();

  Map<DateTime, List<WorkoutInstance>> _workoutInstances = {};
  Map<String, Map<String, num>> _volumeByMuscleGroup = {};
  Map<String, Map<String, num>> _setsByMuscleGroup = {};

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
      final instances = await _workoutService.getHistoricWorkouts();
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
    _workoutInstances = {};
    _volumeByMuscleGroup = {};
    _setsByMuscleGroup = {};

    for (final instance in instances) {
      final date = instance.createdAt;
      final dateKey = DateTime(date.year, date.month, date.day);
      _workoutInstances.putIfAbsent(dateKey, () => []).add(instance);

      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      for (final exercise in instance.exercises) {
        final muscleGroup = exercise.muscleGroup;
        if (muscleGroup != 'unknown') {
          _volumeByMuscleGroup
            .putIfAbsent(muscleGroup, () => {})
            .update(dateStr, (value) => value + exercise.totalVolume, ifAbsent: () => exercise.totalVolume);

          _setsByMuscleGroup
            .putIfAbsent(muscleGroup, () => {})
            .update(dateStr, (value) => value + exercise.sets.length, ifAbsent: () => exercise.sets.length);
        }
      }
    }
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
              _buildFilterDropdowns(),
            ],
          ),
        ),
        ..._buildMuscleGroupCards(),
      ],
    );
  }

  Widget _buildFilterDropdowns() {
    return Row(
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
    final sortedAggregatedData = _sortAggregatedData(aggregatedData, _selectedTimeFrame);

    final percentageChange = _calculatePercentageChange(sortedAggregatedData);

    return _buildMuscleGroupCard(muscleGroup, percentageChange, sortedAggregatedData);
  }).toList();
}

  Widget _buildMuscleGroupCard(String muscleGroup, double percentageChange, List<MapEntry<String, num>> sortedAggregatedData) {
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
                      data[value.toInt()].key,
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

  double _calculateTotal(Map<String, num> data) {
    return data.values.fold(0.0, (sum, value) => sum + value);
  }

  DateTime _parseDate(String dateStr) {
    return DateTime.parse(dateStr);
  }

  Map<String, num> _aggregateData(Map<String, num> data, TimeFrame timeFrame) {
    final now = DateTime.now();
    final aggregatedData = <String, num>{};

    switch (timeFrame) {
      case TimeFrame.week:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        for (int i = 0; i < 7; i++) {
          final day = startOfWeek.add(Duration(days: i));
          final dayKey = DateFormat('E').format(day); // e.g., "Mon", "Tue", etc.
          aggregatedData[dayKey] = 0;
        }
        data.forEach((key, value) {
          final date = _parseDate(key);
          if (date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
              date.isBefore(startOfWeek.add(const Duration(days: 7)))) {
            final dayKey = DateFormat('E').format(date);
            aggregatedData[dayKey] = (aggregatedData[dayKey] ?? 0) + value;
          }
        });

      case TimeFrame.month:
        final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
        for (int i = 0; i < (daysInMonth / 7).ceil(); i++) {
          aggregatedData['Week ${i + 1}'] = 0;
        }
        data.forEach((key, value) {
          final date = _parseDate(key);
          if (date.year == now.year && date.month == now.month) {
            final weekNumber = ((date.day - 1) / 7).floor() + 1;
            final weekKey = 'Week $weekNumber';
            aggregatedData[weekKey] = (aggregatedData[weekKey] ?? 0) + value;
          }
        });

      case TimeFrame.year:
        for (int i = 1; i <= 12; i++) {
          aggregatedData[DateFormat('MMM').format(DateTime(now.year, i))] = 0;
        }
        data.forEach((key, value) {
          final date = _parseDate(key);
          if (date.year == now.year) {
            final monthKey = DateFormat('MMM').format(date);
            aggregatedData[monthKey] = (aggregatedData[monthKey] ?? 0) + value;
          }
        });
    }

      return aggregatedData;
    }

    List<MapEntry<String, num>> _sortAggregatedData(Map<String, num> data, TimeFrame timeFrame) {
      final sortedEntries = data.entries.toList();
      
      switch (timeFrame) {
        case TimeFrame.week:
          final weekDayOrder = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
          sortedEntries.sort((a, b) => weekDayOrder.indexOf(a.key).compareTo(weekDayOrder.indexOf(b.key)));
        case TimeFrame.month:
          sortedEntries.sort((a, b) {
            final weekA = int.parse(a.key.split(' ')[1]);
            final weekB = int.parse(b.key.split(' ')[1]);
            return weekA.compareTo(weekB);
          });
        case TimeFrame.year:
          final monthOrder = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
          sortedEntries.sort((a, b) => monthOrder.indexOf(a.key).compareTo(monthOrder.indexOf(b.key)));
      }
      return sortedEntries;
    }

    double _calculatePercentageChange(List<MapEntry<String, num>> sortedData) {
      if (sortedData.length < 2) return 0.0;

      final nonZeroEntries = sortedData.where((entry) => entry.value != 0).toList();
      
      if (nonZeroEntries.isEmpty) return 0.0;
      
      if (nonZeroEntries.length == 1) {
        return nonZeroEntries.first.value > 0 ? double.infinity : -100.0;
      }

      final firstValue = nonZeroEntries.first.value.toDouble();
      final lastValue = nonZeroEntries.last.value.toDouble();

      return ((lastValue - firstValue) / firstValue) * 100;
    }


    String _formatPercentageChange(double percentageChange) {
      if (percentageChange.isInfinite) {
        return percentageChange > 0 ? '+∞%' : '-∞%';
      }
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
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}