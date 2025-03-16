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
          _buildChartContainer(),
        ],
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
      child: _buildChartTabs(),
    );
  }

  Widget _buildChartTabs() {
    final theme = Theme.of(context);
    final tabBorder = BorderRadius.circular(8);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: const [
              Tab(text: 'Volume', height: 40),
              Tab(text: 'Sets', height: 40),
              Tab(text: 'One Rep Max', height: 40),
            ],
            labelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.7),
            indicatorColor: theme.colorScheme.primary,
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            splashBorderRadius: tabBorder,
            indicator: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: tabBorder,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 320,
          width: double.infinity,
          child: TabBarView(
            controller: _tabController,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: VolumeChart(
                  weeklyVolumeData: _dashboardData.weeklyVolumeData ?? [],
                  selectedTimeFrame: _selectedTimeFrame,
                  onTimeFrameSelected: (timeFrame) {
                    setState(() {
                      _selectedTimeFrame = timeFrame;
                      _fetchWorkoutData();
                    });
                  },
                ),
              ),
              _buildSetsChart(),
              _buildOneRepMaxChart(),
            ],
          ),
        ),
      ],
    );
  }

  // MARK: - Chart Widgets
  Widget _buildSetsChart() {
    if (_dashboardData.setsByMuscleGroup.isEmpty) {
      return _buildEmptyChartIndicator('Sets by Muscle Group');
    }

    // Calculate total sets per muscle group
    final Map<String, int> totalSetsByMuscleGroup = {};
    
    _dashboardData.setsByMuscleGroup.forEach((muscleGroup, dateMap) {
      totalSetsByMuscleGroup[muscleGroup] = dateMap.values
          .fold(0, (total, sets) => total + sets.toInt());
    });
    
    // Sort muscle groups by total sets (descending)
    final sortedMuscleGroups = totalSetsByMuscleGroup.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // Take top 6 muscle groups or all if less than 6
    final topMuscleGroups = sortedMuscleGroups.take(6).toList();
    
    // Generate colors for each muscle group
    final List<Color> muscleGroupColors = [
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.secondary,
      Colors.green.shade600,
      Colors.orange.shade600,
      Colors.purple.shade500,
      Colors.teal.shade600,
    ];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sets by Muscle Group',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: topMuscleGroups.isNotEmpty ? 
                      (topMuscleGroups[0].value * 1.2) : 10,
                  titlesData: _getSetsChartTitles(topMuscleGroups),
                  gridData: _getChartGridData(
                    topMuscleGroups.isNotEmpty && topMuscleGroups[0].value > 0 
                        ? (topMuscleGroups[0].value * 1.2) / 5 
                        : 1.0
                  ),
                  borderData: _getChartBorderData(),
                  barGroups: List.generate(
                    topMuscleGroups.length,
                    (index) => BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: topMuscleGroups[index].value.toDouble(),
                          color: index < muscleGroupColors.length 
                              ? muscleGroupColors[index] 
                              : Theme.of(context).colorScheme.primary,
                          width: 18,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: topMuscleGroups.isNotEmpty ? 
                                (topMuscleGroups[0].value * 1.2) : 10,
                            color: Colors.grey.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildChartLegend(topMuscleGroups, muscleGroupColors),
        ],
      ),
    );
  }
  
  Widget _buildOneRepMaxChart() {
    if (_dashboardData.bestOneRepMaxByExercise.isEmpty) {
      return _buildEmptyChartIndicator('One Rep Max Progress');
    }

    // Sort exercises by their one rep max values (descending)
    final sortedExercises = _dashboardData.bestOneRepMaxByExercise.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // Take top 5 exercises or all if less than 5
    final topExercises = sortedExercises.take(5).toList();
    
    // Generate colors for each exercise
    final List<Color> exerciseColors = [
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.secondary,
      Colors.green.shade600,
      Colors.amber.shade600,
      Colors.purple.shade500,
    ];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'One Rep Max Progress',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: sortedExercises.isNotEmpty ? 
                      (sortedExercises[0].value * 1.2) : 100,
                  minY: 0,
                  titlesData: _getOneRepMaxChartTitles(topExercises),
                  gridData: _getChartGridData(
                    sortedExercises.isNotEmpty && sortedExercises[0].value > 0 
                        ? (sortedExercises[0].value * 1.2) / 5 
                        : 10.0
                  ),
                  borderData: _getChartBorderData(),
                  barGroups: List.generate(
                    topExercises.length,
                    (index) => BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: topExercises[index].value,
                          color: index < exerciseColors.length 
                              ? exerciseColors[index] 
                              : Theme.of(context).colorScheme.primary,
                          width: 18,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: sortedExercises.isNotEmpty ? 
                                (sortedExercises[0].value * 1.2) : 100,
                            color: Colors.grey.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildOneRepMaxLegend(topExercises, exerciseColors),
        ],
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
      horizontalInterval: interval,
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