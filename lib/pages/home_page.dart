import 'package:flutter/material.dart';
import 'dart:async';

// External packages
import 'package:fl_chart/fl_chart.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

// Models and Services
import '../enums.dart';
import '../models/workout_instance.dart';
import '../services/dashboard_service.dart';
import '../services/workout_instance_service.dart';

// Widgets
import '../widgets/dashboard/empty_dashboard.dart';
import '../widgets/dashboard/error_view.dart';
import '../widgets/dashboard/progress_summary_card.dart';
import '../widgets/dashboard/recent_workout_card.dart';
import '../widgets/dashboard/stat_card.dart';
import '../widgets/dashboard/time_frame_filter.dart';
import '../widgets/dashboard/volume_chart.dart';

/// A stateful widget that displays the main dashboard of the workout tracking application.
/// It shows workout statistics, progress charts, and recent workout information.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  // MARK: - Services
  final WorkoutInstanceService _workoutService = WorkoutInstanceService();
  final DashboardService _dashboardService = DashboardService();

  // MARK: - Controllers
  late final RefreshController _refreshController;
  late TabController _tabController;
  
  // MARK: - State
  DashboardResult _dashboardData = DashboardResult();
  TimeFrame _selectedTimeFrame = TimeFrame.last7Days;
  ViewType _selectedViewType = ViewType.volume;
  bool _isLoading = false;
  String? _error;

  // Data for Progress Insights
  GroupBy _selectedGroupBy = GroupBy.muscleGroup;
  String? _selectedMuscleGroup;
  String? _selectedExercise;
  List<String> _muscleGroups = [];
  List<String> _exercises = [];

  // MARK: - Lifecycle Methods
  @override
  void initState() {
    super.initState();
    _initializeControllers();
    Future.microtask(_fetchWorkoutData);
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  // MARK: - Controller Management
  void _initializeControllers() {
    _refreshController = RefreshController(initialRefresh: false);
    _tabController = TabController(length: 3, vsync: this)
      ..addListener(_handleTabChange);
  }

  void _disposeControllers() {
    _refreshController.dispose();
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        _selectedViewType = switch (_tabController.index) {
          0 => ViewType.volume,
          1 => ViewType.sets,
          2 => ViewType.oneRepMax,
          _ => ViewType.volume,
        };
      });
    }
  }

  // MARK: - Data Management
  Future<void> _fetchWorkoutData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final instances = await _workoutService.getHistoricWorkouts()
          .timeout(const Duration(seconds: 10));
      
      if (!mounted) return;
      
      final result = await _dashboardService.processWorkoutInstances(
        instances, 
        _selectedTimeFrame
      );
      
      if (!mounted) return;
      
      setState(() {
        _dashboardData = result;
        _isLoading = false;
        _error = result.error;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
        _error = e is TimeoutException 
            ? 'Loading data timed out. Please try again.'
            : 'Failed to load workout data: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        _refreshController.refreshCompleted();
      }
    }
  }

  // MARK: - Main Build Method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // MARK: - Core UI Components
  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () => Navigator.of(context).pushReplacementNamed('/home', arguments: 2),
      heroTag: 'newWorkout',
      icon: const Icon(Icons.fitness_center),
      label: const Text('New Workout'),
      elevation: 4,
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingView();
    }
    
    if (_error != null) {
      return _buildErrorView();
    }
    
    final dataValid = _dashboardData.workoutInstancesByDate != null && 
                       _dashboardData.weeklyVolumeData != null;
    
    if (!dataValid) {
      return _buildIncompleteDataView();
    }
    
    final allWorkouts = _dashboardData.workoutInstancesByDate?.values.expand((i) => i).toList() ?? [];
    
    if (allWorkouts.isEmpty) {
      return _buildEmptyDashboardView();
    }
    
    return _buildDashboard();
  }

  // MARK: - View States
  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 20),
          Text(
            'Loading your workout data...',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This may take a moment.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _isLoading = false;
                _dashboardData = DashboardResult();
                _error = 'Loading cancelled';
              });
            },
            icon: const Icon(Icons.cancel_outlined),
            label: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return ErrorView(
      errorMessage: _error!,
      onRetry: _fetchWorkoutData,
      onStartNewWorkout: () => Navigator.of(context).pushReplacementNamed('/home', arguments: 2),
    );
  }

  Widget _buildIncompleteDataView() {
    return ErrorView(
      errorMessage: 'Failed to load workout data. Data structure is incomplete.',
      onRetry: _fetchWorkoutData,
      onStartNewWorkout: () => Navigator.of(context).pushReplacementNamed('/home', arguments: 2),
    );
  }

  Widget _buildEmptyDashboardView() {
    return EmptyDashboard(
      onStartWorkout: () => Navigator.of(context).pushReplacementNamed('/home', arguments: 2),
    );
  }

  // MARK: - Dashboard UI
  Widget _buildDashboard() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            isDarkMode 
                ? theme.colorScheme.surface 
                : theme.colorScheme.primary.withOpacity(0.05),
            theme.scaffoldBackgroundColor,
          ],
          stops: const [0.0, 0.3],
        ),
      ),
      child: SmartRefresher(
        controller: _refreshController,
        onRefresh: _fetchWorkoutData,
        enablePullDown: true,
        enablePullUp: false,
        header: const WaterDropHeader(),
        child: _buildDashboardContent(),
      ),
    );
  }

  Widget _buildDashboardContent() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 16,
                      bottom: 16,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.fitness_center,
                            size: 24,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Dashboard',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        onPressed: _fetchWorkoutData,
                        tooltip: 'Refresh data',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(
            left: 16, 
            right: 16, 
            top: 16, 
            bottom: 80, // Extra padding for FAB
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildWelcomeSection(),
              const SizedBox(height: 24),
              _buildStatCardsSection(),
              const SizedBox(height: 24),
              _buildProgressSummarySection(),
              const SizedBox(height: 24),
              _buildChartsSection(),
            ]),
          ),
        ),
      ],
    );
  }

  // MARK: - Dashboard Sections
  Widget _buildWelcomeSection() {
    final theme = Theme.of(context);
    final lastWorkoutDate = _dashboardData.lastWorkoutDate;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, Omar!',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastWorkoutDate != null 
                        ? 'Last workout: ${_formatShortDate(lastWorkoutDate)}'
                        : 'Ready for your workout?',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              _buildWorkoutStreak(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutStreak() {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.shade400,
            Colors.red.shade400,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 4),
          Text(
            '${_dashboardData.workoutStreak ?? 0} days',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCardsSection() {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Workouts This Year',
            value: (_dashboardData.yearlyWorkouts ?? 0).toString(),
            icon: Icons.fitness_center,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            title: 'Total Volume',
            value: '${(_dashboardData.totalVolume ?? 0).toStringAsFixed(0)} lbs',
            icon: Icons.bar_chart,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSummarySection() {
    if (_dashboardData.lastWorkoutDate == null) {
      return const SizedBox.shrink();
    }
    
    return ProgressSummaryCard(
      lastWorkoutDate: _dashboardData.lastWorkoutDate,
      thisWeekVolume: _dashboardData.thisWeekVolume ?? 0,
      lastWeekVolume: _dashboardData.lastWeekVolume ?? 0,
      workoutStreak: _dashboardData.workoutStreak ?? 0,
      totalWorkouts: _dashboardData.totalWorkouts ?? 0,
    );
  }

  Widget _buildChartsSection() {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildChartsSectionHeader(),
          ),
          // Check if there's any data available
          _hasInsightData() 
              ? Column(
                  children: [
                    _buildProgressInsightControls(),
                    _buildChartContainer(),
                  ],
                )
              : _buildNoInsightDataMessage(),
        ],
      ),
    );
  }

  bool _hasInsightData() {
    return _dashboardData.volumeByMuscleGroup.isNotEmpty || 
           _dashboardData.oneRepMaxByExercise.isNotEmpty || 
           _dashboardData.setsByMuscleGroup.isNotEmpty;
  }

  Widget _buildNoInsightDataMessage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.insights,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No workout data available yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete a few workouts to see insights about your progress over time.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pushReplacementNamed('/home', arguments: 2),
              icon: const Icon(Icons.fitness_center),
              label: const Text('Start a Workout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSectionHeader() {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'Progress Insights',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
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

  Widget _buildProgressInsightControls() {
    // Initialize muscle groups and exercises if needed
    if (_muscleGroups.isEmpty && _dashboardData.volumeByMuscleGroup.isNotEmpty) {
      _muscleGroups = _dashboardData.volumeByMuscleGroup.keys.toList()..sort();
      if (_selectedMuscleGroup == null && _muscleGroups.isNotEmpty) {
        _selectedMuscleGroup = _muscleGroups.first;
      }
    }
    
    if (_exercises.isEmpty && _dashboardData.oneRepMaxByExercise.isNotEmpty) {
      _exercises = _dashboardData.oneRepMaxByExercise.keys.toList()..sort();
      if (_selectedExercise == null && _exercises.isNotEmpty) {
        _selectedExercise = _exercises.first;
      }
    }

    // If the selected group doesn't have any data available, automatically switch to the other option
    if (_selectedGroupBy == GroupBy.muscleGroup && _muscleGroups.isEmpty && _exercises.isNotEmpty) {
      _selectedGroupBy = GroupBy.exercise;
    } else if (_selectedGroupBy == GroupBy.exercise && _exercises.isEmpty && _muscleGroups.isNotEmpty) {
      _selectedGroupBy = GroupBy.muscleGroup;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          // Group By selector
          Row(
            children: [
              const Text('Group By:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 16),
              Flexible(
                child: SegmentedButton<GroupBy>(
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
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Selection dropdown based on groupBy
          _selectedGroupBy == GroupBy.muscleGroup
            ? _buildMuscleGroupDropdown()
            : _buildExerciseDropdown(),
          
          // View type selector
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('View:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 16),
              Flexible(
                child: SegmentedButton<ViewType>(
                  segments: _selectedGroupBy == GroupBy.muscleGroup
                    ? const [
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
                      ]
                    : const [
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
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMuscleGroupDropdown() {
    if (_muscleGroups.isEmpty) {
      return const Text('No muscle groups found');
    }
    
    return Row(
      children: [
        const Text('Muscle Group:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 16),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: _selectedMuscleGroup,
              isExpanded: true,
              underline: Container(), // Remove the default underline
              dropdownColor: Theme.of(context).colorScheme.surface,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
              ),
              icon: Icon(
                Icons.arrow_drop_down,
                color: Theme.of(context).colorScheme.primary,
              ),
              items: _muscleGroups.map((group) {
                return DropdownMenuItem<String>(
                  value: group,
                  child: Text(
                    group,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  ),
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
        ),
      ],
    );
  }

  Widget _buildExerciseDropdown() {
    if (_exercises.isEmpty) {
      return const Text('No exercises found');
    }
    
    return Row(
      children: [
        const Text('Exercise:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 16),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: _selectedExercise,
              isExpanded: true,
              underline: Container(), // Remove the default underline
              dropdownColor: Theme.of(context).colorScheme.surface,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
              ),
              icon: Icon(
                Icons.arrow_drop_down,
                color: Theme.of(context).colorScheme.primary,
              ),
              items: _exercises.map((exercise) {
                return DropdownMenuItem<String>(
                  value: exercise,
                  child: Text(
                    exercise,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  ),
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
        ),
      ],
    );
  }

  Widget _buildChartContainer() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode 
            ? theme.colorScheme.surface.withOpacity(0.8)
            : Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.1),
        ),
      ),
      child: _buildSelectedChart(),
    );
  }

  Widget _buildSelectedChart() {
    if (_selectedGroupBy == GroupBy.muscleGroup) {
      // Show muscle group charts
      if (_selectedMuscleGroup == null || _muscleGroups.isEmpty) {
        return _buildInsightEmptyChartIndicator('Select a muscle group');
      }
      
      if (_selectedViewType == ViewType.volume) {
        return _buildMuscleGroupVolumeChart();
      } else {
        return _buildMuscleGroupSetsChart();
      }
    } else {
      // Show exercise charts
      if (_selectedExercise == null || _exercises.isEmpty) {
        return _buildInsightEmptyChartIndicator('Select an exercise');
      }
      
      if (_selectedViewType == ViewType.volume) {
        return _buildExerciseVolumeChart();
      } else if (_selectedViewType == ViewType.sets) {
        return _buildExerciseSetsChart();
      } else {
        return _buildExerciseOneRepMaxChart();
      }
    }
  }

  Widget _buildMuscleGroupVolumeChart() {
    if (_selectedMuscleGroup == null || 
        !_dashboardData.volumeByMuscleGroup.containsKey(_selectedMuscleGroup)) {
      return _buildInsightEmptyChartIndicator('No volume data for $_selectedMuscleGroup');
    }

    final volumeData = _dashboardData.volumeByMuscleGroup[_selectedMuscleGroup]!;
    if (volumeData.isEmpty) {
      return _buildInsightEmptyChartIndicator('No volume data available');
    }

    // Convert map data to chart data for LineChart
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

    return _buildInsightLineChart(
      spots, 
      'Volume (kg) - $_selectedMuscleGroup', 
      chartData.map((e) => e.key).toList()
    );
  }

  Widget _buildMuscleGroupSetsChart() {
    if (_selectedMuscleGroup == null || 
        !_dashboardData.setsByMuscleGroup.containsKey(_selectedMuscleGroup)) {
      return _buildInsightEmptyChartIndicator('No sets data for $_selectedMuscleGroup');
    }

    final setsData = _dashboardData.setsByMuscleGroup[_selectedMuscleGroup]!;
    if (setsData.isEmpty) {
      return _buildInsightEmptyChartIndicator('No sets data available');
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

    return _buildInsightLineChart(
      spots, 
      'Number of Sets - $_selectedMuscleGroup', 
      chartData.map((e) => e.key).toList()
    );
  }

  Widget _buildExerciseVolumeChart() {
    if (_selectedExercise == null) {
      return _buildInsightEmptyChartIndicator('No exercise selected');
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
      return _buildInsightEmptyChartIndicator('No volume data for $_selectedExercise');
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

    return _buildInsightLineChart(
      spots, 
      'Volume (kg) - $_selectedExercise', 
      chartData.map((e) => e.key).toList()
    );
  }

  Widget _buildExerciseSetsChart() {
    if (_selectedExercise == null) {
      return _buildInsightEmptyChartIndicator('No exercise selected');
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
      return _buildInsightEmptyChartIndicator('No sets data for $_selectedExercise');
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

    return _buildInsightLineChart(
      spots, 
      'Number of Sets - $_selectedExercise', 
      chartData.map((e) => e.key).toList()
    );
  }

  Widget _buildExerciseOneRepMaxChart() {
    if (_selectedExercise == null || 
        !_dashboardData.oneRepMaxByExercise.containsKey(_selectedExercise)) {
      return _buildInsightEmptyChartIndicator('No 1RM data for $_selectedExercise');
    }

    final oneRepMaxData = _dashboardData.oneRepMaxByExercise[_selectedExercise]!;
    if (oneRepMaxData.isEmpty) {
      return _buildInsightEmptyChartIndicator('No 1RM data available');
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

    return _buildInsightLineChart(
      spots, 
      '1 Rep Max (kg) - $_selectedExercise', 
      chartData.map((e) => e.key).toList(),
      isOneRepMax: true,
    );
  }

  Widget _buildInsightLineChart(
    List<FlSpot> spots, 
    String title, 
    List<DateTime> dates, 
    {bool isOneRepMax = false}
  ) {
    if (spots.isEmpty) {
      return _buildInsightEmptyChartIndicator('No data available for the chart');
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

    return Container(
      height: 320,
      padding: const EdgeInsets.all(16.0),
      child: Column(
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
      ),
    );
  }

  Widget _buildInsightEmptyChartIndicator(String message) {
    return SizedBox(
      height: 320,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 64,
              color: Colors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // MARK: - Helper Widgets
  Widget _buildEmptyChartIndicator(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Icon(
            Icons.bar_chart,
            size: 48,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No data available yet.\nComplete workouts to see your progress!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartLegend(List<MapEntry<String, int>> items, List<Color> colors) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        for (int i = 0; i < items.length; i++)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: i < colors.length 
                      ? colors[i] 
                      : Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                items[i].key,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildOneRepMaxLegend(List<MapEntry<String, double>> items, List<Color> colors) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        for (int i = 0; i < items.length; i++)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: i < colors.length 
                      ? colors[i] 
                      : Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${items[i].key}: ${items[i].value.toStringAsFixed(1)} lbs',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
      ],
    );
  }

  // MARK: - Chart Configuration Methods
  FlTitlesData _getSetsChartTitles(List<MapEntry<String, int>> muscleGroups) {
    return FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            if (value < 0 || value >= muscleGroups.length) {
              return const SizedBox.shrink();
            }
            
            String muscleGroup = muscleGroups[value.toInt()].key;
            if (muscleGroup.length > 8) {
              muscleGroup = '${muscleGroup.substring(0, 6)}...';
            }
            
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                muscleGroup,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
          reservedSize: 40,
        ),
      ),
      leftTitles: _getLeftAxisTitles(),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  FlTitlesData _getOneRepMaxChartTitles(List<MapEntry<String, double>> exercises) {
    return FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            if (value < 0 || value >= exercises.length) {
              return const SizedBox.shrink();
            }
            
            String exerciseName = exercises[value.toInt()].key;
            if (exerciseName.length > 10) {
              exerciseName = '${exerciseName.substring(0, 8)}...';
            }
            
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                exerciseName,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
          reservedSize: 40,
        ),
      ),
      leftTitles: _getLeftAxisTitles(),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  AxisTitles _getLeftAxisTitles() {
    return AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        getTitlesWidget: (value, meta) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0, left: 4.0),
            child: Text(
              value.toInt().toString(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
        reservedSize: 40,
      ),
    );
  }

  FlGridData _getChartGridData(double interval) {
    return FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: interval <= 0 ? 1.0 : interval,
      getDrawingHorizontalLine: (value) => FlLine(
        color: Colors.grey.withOpacity(0.2),
        strokeWidth: 1,
      ),
    );
  }

  FlBorderData _getChartBorderData() {
    return FlBorderData(
      show: true,
      border: Border(
        bottom: BorderSide(
          color: Colors.grey.withOpacity(0.4),
          width: 1,
        ),
        left: BorderSide(
          color: Colors.grey.withOpacity(0.4),
          width: 1,
        ),
      ),
    );
  }

  // MARK: - Utilities
  String _formatShortDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);
    
    if (dateToCheck == today) return 'Today';
    if (dateToCheck == yesterday) return 'Yesterday';
    
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }
}