import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../enums.dart';
import '../models/workout_instance.dart';
import '../services/dashboard_service.dart';
import '../services/workout_instance_service.dart';
import '../widgets/dashboard/time_frame_filter.dart';

class ProgressInsightsPage extends StatefulWidget {
  const ProgressInsightsPage({super.key});

  @override
  State<ProgressInsightsPage> createState() => _ProgressInsightsPageState();
}

class _ProgressInsightsPageState extends State<ProgressInsightsPage> {
  final WorkoutInstanceService _workoutService = WorkoutInstanceService();
  final DashboardService _dashboardService = DashboardService();
  
  bool _isLoading = true;
  String? _error;
  DashboardResult _dashboardData = DashboardResult();
  TimeFrame _selectedTimeFrame = TimeFrame.lastMonth;
  GroupBy _selectedGroupBy = GroupBy.muscleGroup;
  ViewType _selectedViewType = ViewType.volume;
  
  String? _selectedMuscleGroup;
  String? _selectedExercise;
  
  List<String> _muscleGroups = [];
  List<String> _exercises = [];

  @override
  void initState() {
    super.initState();
    _fetchWorkoutData();
  }

  Future<void> _fetchWorkoutData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final workouts = await _workoutService.getHistoricWorkouts();
      final dashboardData = _dashboardService.processWorkoutInstances(
        workouts, 
        _selectedTimeFrame
      );

      if (dashboardData.error != null) {
        setState(() {
          _error = dashboardData.error;
          _isLoading = false;
        });
        return;
      }

      // Extract available muscle groups
      _muscleGroups = dashboardData.volumeByMuscleGroup.keys.toList()..sort();
      
      // Extract available exercises
      _exercises = dashboardData.oneRepMaxByExercise.keys.toList()..sort();

      // Set initial selections if not already set
      if (_selectedMuscleGroup == null && _muscleGroups.isNotEmpty) {
        _selectedMuscleGroup = _muscleGroups.first;
      }
      
      if (_selectedExercise == null && _exercises.isNotEmpty) {
        _selectedExercise = _exercises.first;
      }

      setState(() {
        _dashboardData = dashboardData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Insights'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchWorkoutData,
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _error != null
          ? Center(child: Text('Error: $_error'))
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group By selector
          _buildGroupBySelector(),
          const SizedBox(height: 16),
          
          // Selection dropdown based on groupBy
          _selectedGroupBy == GroupBy.muscleGroup
            ? _buildMuscleGroupSelector()
            : _buildExerciseSelector(),
          const SizedBox(height: 16),
          
          // Time frame selector
          _buildTimeFrameSelector(),
          const SizedBox(height: 16),
          
          // View type selector (only show for muscle groups)
          if (_selectedGroupBy == GroupBy.muscleGroup)
            _buildViewTypeSelector(),
          
          if (_selectedGroupBy == GroupBy.exercise)
            _buildViewTypeSelectorForExercise(),
          
          const SizedBox(height: 24),
          
          // Progress chart
          Expanded(
            child: _buildProgressChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupBySelector() {
    return Row(
      children: [
        const Text('Group By:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 16),
        SegmentedButton<GroupBy>(
          segments: const [
            ButtonSegment<GroupBy>(
              value: GroupBy.muscleGroup,
              label: Text('Muscle Group'),
              icon: Icon(Icons.fitness_center),
            ),
            ButtonSegment<GroupBy>(
              value: GroupBy.exercise,
              label: Text('Exercise'),
              icon: Icon(Icons.sports_gymnastics),
            ),
          ],
          selected: {_selectedGroupBy},
          onSelectionChanged: (Set<GroupBy> selection) {
            setState(() {
              _selectedGroupBy = selection.first;
              
              // Reset view type when switching group by
              if (_selectedGroupBy == GroupBy.muscleGroup) {
                _selectedViewType = ViewType.volume;
              } else {
                _selectedViewType = ViewType.oneRepMax;
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildMuscleGroupSelector() {
    if (_muscleGroups.isEmpty) {
      return const Text('No muscle groups found');
    }
    
    return Row(
      children: [
        const Text('Muscle Group:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 16),
        Expanded(
          child: DropdownButton<String>(
            value: _selectedMuscleGroup,
            isExpanded: true,
            items: _muscleGroups.map((group) {
              return DropdownMenuItem<String>(
                value: group,
                child: Text(group),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedMuscleGroup = newValue;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseSelector() {
    if (_exercises.isEmpty) {
      return const Text('No exercises found');
    }
    
    return Row(
      children: [
        const Text('Exercise:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 16),
        Expanded(
          child: DropdownButton<String>(
            value: _selectedExercise,
            isExpanded: true,
            items: _exercises.map((exercise) {
              return DropdownMenuItem<String>(
                value: exercise,
                child: Text(exercise),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedExercise = newValue;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimeFrameSelector() {
    return Row(
      children: [
        const Text('Time Frame:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 16),
        TimeFrameFilter(
          selectedTimeFrame: _selectedTimeFrame,
          onTimeFrameSelected: (timeFrame) {
            setState(() {
              _selectedTimeFrame = timeFrame;
              _fetchWorkoutData();
            });
          },
        ),
      ],
    );
  }

  Widget _buildViewTypeSelector() {
    return Row(
      children: [
        const Text('View:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 16),
        SegmentedButton<ViewType>(
          segments: const [
            ButtonSegment<ViewType>(
              value: ViewType.volume,
              label: Text('Volume'),
              icon: Icon(Icons.bar_chart),
            ),
            ButtonSegment<ViewType>(
              value: ViewType.sets,
              label: Text('Sets'),
              icon: Icon(Icons.numbers),
            ),
          ],
          selected: {_selectedViewType},
          onSelectionChanged: (Set<ViewType> selection) {
            setState(() {
              _selectedViewType = selection.first;
            });
          },
        ),
      ],
    );
  }

  Widget _buildViewTypeSelectorForExercise() {
    return Row(
      children: [
        const Text('View:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 16),
        SegmentedButton<ViewType>(
          segments: const [
            ButtonSegment<ViewType>(
              value: ViewType.volume,
              label: Text('Volume'),
              icon: Icon(Icons.bar_chart),
            ),
            ButtonSegment<ViewType>(
              value: ViewType.sets,
              label: Text('Sets'),
              icon: Icon(Icons.numbers),
            ),
            ButtonSegment<ViewType>(
              value: ViewType.oneRepMax,
              label: Text('1RM'),
              icon: Icon(Icons.fitness_center),
            ),
          ],
          selected: {_selectedViewType},
          onSelectionChanged: (Set<ViewType> selection) {
            setState(() {
              _selectedViewType = selection.first;
            });
          },
        ),
      ],
    );
  }

  Widget _buildProgressChart() {
    if (_selectedGroupBy == GroupBy.muscleGroup) {
      if (_selectedViewType == ViewType.volume) {
        return _buildVolumeChart();
      } else {
        return _buildSetsChart();
      }
    } else {
      if (_selectedViewType == ViewType.volume) {
        return _buildExerciseVolumeChart();
      } else if (_selectedViewType == ViewType.sets) {
        return _buildExerciseSetsChart();
      } else {
        return _buildOneRepMaxChart();
      }
    }
  }

  Widget _buildVolumeChart() {
    if (_selectedMuscleGroup == null || 
        !_dashboardData.volumeByMuscleGroup.containsKey(_selectedMuscleGroup)) {
      return Center(child: Text('No volume data for $_selectedMuscleGroup'));
    }

    final volumeData = _dashboardData.volumeByMuscleGroup[_selectedMuscleGroup]!;
    if (volumeData.isEmpty) {
      return const Center(child: Text('No volume data available'));
    }

    // Convert map data to chart data
    List<MapEntry<DateTime, double>> chartData = [];
    volumeData.forEach((dateStr, volume) {
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        final date = DateTime(
          int.parse(parts[0]), 
          int.parse(parts[1]), 
          int.parse(parts[2])
        );
        chartData.add(MapEntry(date, volume.toDouble()));
      }
    });

    // Sort by date
    chartData.sort((a, b) => a.key.compareTo(b.key));

    // Create spots for the chart
    final spots = chartData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();

    return _buildLineChart(
      spots, 
      'Volume (kg) - $_selectedMuscleGroup', 
      chartData.map((e) => e.key).toList()
    );
  }

  Widget _buildSetsChart() {
    if (_selectedMuscleGroup == null || 
        !_dashboardData.setsByMuscleGroup.containsKey(_selectedMuscleGroup)) {
      return Center(child: Text('No sets data for $_selectedMuscleGroup'));
    }

    final setsData = _dashboardData.setsByMuscleGroup[_selectedMuscleGroup]!;
    if (setsData.isEmpty) {
      return const Center(child: Text('No sets data available'));
    }

    // Convert map data to chart data
    List<MapEntry<DateTime, double>> chartData = [];
    setsData.forEach((dateStr, sets) {
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        final date = DateTime(
          int.parse(parts[0]), 
          int.parse(parts[1]), 
          int.parse(parts[2])
        );
        chartData.add(MapEntry(date, sets.toDouble()));
      }
    });

    // Sort by date
    chartData.sort((a, b) => a.key.compareTo(b.key));

    // Create spots for the chart
    final spots = chartData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();

    return _buildLineChart(
      spots, 
      'Number of Sets - $_selectedMuscleGroup', 
      chartData.map((e) => e.key).toList()
    );
  }

  Widget _buildExerciseVolumeChart() {
    if (_selectedExercise == null) {
      return const Center(child: Text('No exercise selected'));
    }

    // Extract volume data for the selected exercise
    Map<String, double> volumeData = {};
    _dashboardData.workoutInstancesByDate.forEach((date, instances) {
      for (final instance in instances) {
        for (final exercise in instance.exercises) {
          if (exercise.name == _selectedExercise) {
            final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
            volumeData.update(
              dateStr, 
              (value) => value + exercise.totalVolume, 
              ifAbsent: () => exercise.totalVolume
            );
          }
        }
      }
    });

    if (volumeData.isEmpty) {
      return Center(child: Text('No volume data for $_selectedExercise'));
    }

    // Convert map data to chart data
    List<MapEntry<DateTime, double>> chartData = [];
    volumeData.forEach((dateStr, volume) {
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        final date = DateTime(
          int.parse(parts[0]), 
          int.parse(parts[1]), 
          int.parse(parts[2])
        );
        chartData.add(MapEntry(date, volume));
      }
    });

    // Sort by date
    chartData.sort((a, b) => a.key.compareTo(b.key));

    // Create spots for the chart
    final spots = chartData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();

    return _buildLineChart(
      spots, 
      'Volume (kg) - $_selectedExercise', 
      chartData.map((e) => e.key).toList()
    );
  }

  Widget _buildExerciseSetsChart() {
    if (_selectedExercise == null) {
      return const Center(child: Text('No exercise selected'));
    }

    // Extract sets data for the selected exercise
    Map<String, int> setsData = {};
    _dashboardData.workoutInstancesByDate.forEach((date, instances) {
      for (final instance in instances) {
        for (final exercise in instance.exercises) {
          if (exercise.name == _selectedExercise) {
            final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
            setsData.update(
              dateStr, 
              (value) => value + exercise.sets.length, 
              ifAbsent: () => exercise.sets.length
            );
          }
        }
      }
    });

    if (setsData.isEmpty) {
      return Center(child: Text('No sets data for $_selectedExercise'));
    }

    // Convert map data to chart data
    List<MapEntry<DateTime, double>> chartData = [];
    setsData.forEach((dateStr, sets) {
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        final date = DateTime(
          int.parse(parts[0]), 
          int.parse(parts[1]), 
          int.parse(parts[2])
        );
        chartData.add(MapEntry(date, sets.toDouble()));
      }
    });

    // Sort by date
    chartData.sort((a, b) => a.key.compareTo(b.key));

    // Create spots for the chart
    final spots = chartData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();

    return _buildLineChart(
      spots, 
      'Number of Sets - $_selectedExercise', 
      chartData.map((e) => e.key).toList()
    );
  }

  Widget _buildOneRepMaxChart() {
    if (_selectedExercise == null || 
        !_dashboardData.oneRepMaxByExercise.containsKey(_selectedExercise)) {
      return Center(child: Text('No 1RM data for $_selectedExercise'));
    }

    final oneRepMaxData = _dashboardData.oneRepMaxByExercise[_selectedExercise]!;
    if (oneRepMaxData.isEmpty) {
      return const Center(child: Text('No 1RM data available'));
    }

    // Convert map data to chart data
    List<MapEntry<DateTime, double>> chartData = [];
    oneRepMaxData.forEach((dateStr, oneRepMax) {
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        final date = DateTime(
          int.parse(parts[0]), 
          int.parse(parts[1]), 
          int.parse(parts[2])
        );
        chartData.add(MapEntry(date, oneRepMax));
      }
    });

    // Sort by date
    chartData.sort((a, b) => a.key.compareTo(b.key));

    // Create spots for the chart
    final spots = chartData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();

    return _buildLineChart(
      spots, 
      '1 Rep Max (kg) - $_selectedExercise', 
      chartData.map((e) => e.key).toList(),
      isOneRepMax: true,
    );
  }

  Widget _buildLineChart(
    List<FlSpot> spots, 
    String title, 
    List<DateTime> dates, 
    {bool isOneRepMax = false}
  ) {
    if (spots.isEmpty) {
      return const Center(child: Text('No data available for the chart'));
    }

    // Find min and max values for better scaling
    double minY = spots.map((e) => e.y).reduce((a, b) => a < b ? a : b);
    double maxY = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    
    // Add some padding
    minY = (minY * 0.9).floorToDouble();
    maxY = (maxY * 1.1).ceilToDouble();
    
    // Ensure positive min value
    minY = minY < 0 ? 0 : minY;
    
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: maxY == minY ? 1.0 : (maxY - minY) / 5,
                verticalInterval: 1,
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < dates.length) {
                        return Text(
                          '${dates[index].month}/${dates[index].day}',
                          style: const TextStyle(fontSize: 10),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                    interval: dates.length > 10 ? dates.length / 10 : 1,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 42,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: const Color(0xff37434d), width: 1),
              ),
              minX: 0,
              maxX: spots.length - 1.0,
              minY: minY,
              maxY: maxY,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: false,
                  color: primaryColor,
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 6,
                        color: primaryColor,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: primaryColor.withOpacity(0.2),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (List<LineBarSpot> touchedSpots) {
                    return touchedSpots.map((LineBarSpot touchedSpot) {
                      final index = touchedSpot.x.toInt();
                      if (index >= 0 && index < dates.length) {
                        final date = dates[index];
                        return LineTooltipItem(
                          '${date.month}/${date.day}/${date.year}\n',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                              text: isOneRepMax ? 
                                '1RM: ${touchedSpot.y.toStringAsFixed(1)} kg' : 
                                '${touchedSpot.y.toStringAsFixed(1)}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        );
                      }
                      return null;
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
} 