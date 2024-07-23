import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '/services/workout_instance_service.dart';
import '/models/workout_instance.dart';
import '../enums.dart';
import '../widgets/muscle_group_comparison.dart';

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

      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
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
        buildMuscleGroupComparison(
          context,
          _selectedViewType,
          _selectedTimeFrame,
          _volumeByMuscleGroup,
          _setsByMuscleGroup,
          (dynamic newValue) {
            if (newValue is ViewType) {
              setState(() {
                _selectedViewType = newValue;
              });
            }
          },
          (dynamic newValue) {
            if (newValue is TimeFrame) {
              setState(() {
                _selectedTimeFrame = newValue;
              });
            }
          },
        ),
      ],
    ),
  );
}
}