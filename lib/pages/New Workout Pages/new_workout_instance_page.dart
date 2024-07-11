import 'package:flutter/material.dart';
import '/models/workout.dart';
import 'dart:async';
import '/models/workout_instance.dart';
import '/services/workout_instance_service.dart';
import '/models/exercise.dart';

class NewWorkoutInstancePage extends StatefulWidget {
  final Workout workout;

  const NewWorkoutInstancePage({Key? key, required this.workout}) : super(key: key);

  @override
  NewWorkoutInstancePageState createState() => NewWorkoutInstancePageState();
}

class NewWorkoutInstancePageState extends State<NewWorkoutInstancePage> {
  final _formKey = GlobalKey<FormState>();
  final List<ExerciseInstance> _exerciseInstances = [];
  WorkoutInstance? _lastWorkoutInstance;
  late Future<void> _loadDataFuture;
  Timer? _timer;
  int _timerSeconds = 0;
  int _timerMilliseconds = 0;
  late int _currentExerciseRestPeriod;

  @override
  void initState() {
    super.initState();
    _loadDataFuture = _loadLastWorkoutInstance();
    _startTimer();
    _currentExerciseRestPeriod = widget.workout.exercises.first.restPeriod;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadLastWorkoutInstance() async {
    _lastWorkoutInstance = await WorkoutInstanceService().getLastWorkoutInstance(widget.workout.name);

    for (var exercise in widget.workout.exercises) {
      final lastExerciseInstance = _lastWorkoutInstance?.exercises.firstWhere(
        (e) => e.name == exercise.name,
        orElse: () => ExerciseInstance(name: exercise.name, sets: []),
      );

      final sets = List.generate(
        exercise.sets,
        (index) {
          double weight = 0.0;
          int reps = 0;
          if (lastExerciseInstance != null && lastExerciseInstance.sets.length > index) {
            weight = lastExerciseInstance.sets[index].weight;
            reps = lastExerciseInstance.sets[index].reps;
          }
          return SetDetails(
            setNumber: index + 1,
            weight: weight,
            reps: reps,
          );
        },
      );
      _exerciseInstances.add(ExerciseInstance(name: exercise.name, sets: sets));
    }
  }

  void _saveWorkoutInstance() {
    if (_formKey.currentState!.validate()) {
      final workoutInstance = WorkoutInstance(
        name: widget.workout.name,
        exercises: _exerciseInstances,
        createdAt: DateTime.now(),
      );

      WorkoutInstanceService().addWorkoutInstance(workoutInstance).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workout instance saved successfully')),
        );
        Navigator.pop(context);
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving workout instance: $error')),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
    }
  }

  void _moveExercise(int oldIndex, int newIndex) {
    setState(() {
      final exercise = _exerciseInstances.removeAt(oldIndex);
      _exerciseInstances.insert(newIndex, exercise);
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _timerMilliseconds += 100;
        if (_timerMilliseconds >= 1000) {
          _timerSeconds++;
          _timerMilliseconds = 0;
        }
      });
    });
  }

  void _resetTimer(int restPeriod) {
    setState(() {
      _timerSeconds = 0;
      _timerMilliseconds = 0;
      _currentExerciseRestPeriod = restPeriod;
    });
  }

  void _addSet(int exerciseIndex) {
    setState(() {
      final exercise = _exerciseInstances[exerciseIndex];
      final newSet = SetDetails(setNumber: exercise.sets.length + 1, weight: 0.0, reps: 0);
      exercise.sets.add(newSet);
    });
  }

  Future<String?> _showAddExerciseDialog() async {
  String? exerciseName;
  return showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Add New Exercise'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter exercise name'),
          onChanged: (value) {
            exerciseName = value;
          },
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Add'),
            onPressed: () {
              Navigator.of(context).pop(exerciseName);
            },
          ),
        ],
      );
    },
  );
}

  void _addExercise() async {
    final exerciseName = await _showAddExerciseDialog();
    if (exerciseName != null && exerciseName.isNotEmpty) {
      setState(() {
        final newExercise = ExerciseInstance(name: exerciseName, sets: [
          SetDetails(setNumber: 1, weight: 0.0, reps: 0),
        ]);
        _exerciseInstances.add(newExercise);
      });
    }
  }

  void _deleteExercise(int index) {
    setState(() {
      _exerciseInstances.removeAt(index);
    });
  }

  void _deleteSet(int exerciseIndex, int setIndex) {
    setState(() {
      _exerciseInstances[exerciseIndex].sets.removeAt(setIndex);
      _renumberSets(_exerciseInstances[exerciseIndex]);
    });
  }

  void _renumberSets(ExerciseInstance exercise) {
    for (int i = 0; i < exercise.sets.length; i++) {
      exercise.sets[i].setNumber = i + 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workout.name),
        actions: [
          TextButton(
            onPressed: _saveWorkoutInstance,
            child: const Text('Finish', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _loadDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return _buildWorkoutForm();
          }
        },
      ),
    );
  }

  Widget _buildWorkoutForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    ..._exerciseInstances.map(_buildExerciseCard).toList(),
                    _buildAddExerciseButton(),
                  ],
                ),
              ),
            ),
          ),
          _buildTimer(),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(ExerciseInstance exercise) {
    final exerciseIndex = _exerciseInstances.indexOf(exercise);
    final templateExercise = widget.workout.exercises.firstWhere(
      (e) => e.name == exercise.name,
      orElse: () => Exercise(name: 'Unknown', sets: 0, restPeriod: 0),
    );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: const Color.fromARGB(255, 241, 246, 249),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildExerciseHeader(exercise, exerciseIndex),
            const SizedBox(height: 8),
            _buildPreviousWorkoutInfo(exercise),
            ...exercise.sets.map((set) => _buildSetRow(set, exerciseIndex, templateExercise)).toList(),
            _buildAddSetButton(exerciseIndex),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseHeader(ExerciseInstance exercise, int exerciseIndex) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          exercise.name,
          style: const TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_upward),
              onPressed: exerciseIndex > 0 ? () => _moveExercise(exerciseIndex, exerciseIndex - 1) : null,
            ),
            IconButton(
              icon: const Icon(Icons.arrow_downward),
              onPressed: exerciseIndex < _exerciseInstances.length - 1 ? () => _moveExercise(exerciseIndex, exerciseIndex + 1) : null,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteExercise(exerciseIndex),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPreviousWorkoutInfo(ExerciseInstance exercise) {
    final previousExercise = _lastWorkoutInstance?.exercises.firstWhere(
      (e) => e.name == exercise.name,
      orElse: () => ExerciseInstance(name: exercise.name, sets: []),
    );

    if (previousExercise == null || previousExercise.sets.isEmpty) {
      return const Text('No previous data available', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Previous Workout', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...previousExercise.sets.map((set) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(
            'Set ${set.setNumber}: ${set.weight} lb x ${set.reps} reps',
            style: const TextStyle(color: Colors.black),
          ),
        )),
        const Divider(thickness: 1),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildSetRow(SetDetails set, int exerciseIndex, Exercise templateExercise) {
    final setIndex = _exerciseInstances[exerciseIndex].sets.indexOf(set);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(labelText: 'Set ${set.setNumber} - lbs'),
                keyboardType: TextInputType.number,
                initialValue: set.weight.toString(),
                onChanged: (value) {
                  set.weight = double.tryParse(value) ?? 0.0;
                  _resetTimer(templateExercise.restPeriod);
                },
                validator: (value) => (value == null || value.isEmpty) ? 'Enter weight' : null,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(labelText: 'Reps'),
                keyboardType: TextInputType.number,
                initialValue: set.reps.toString(),
                onChanged: (value) {
                  set.reps = int.tryParse(value) ?? 0;
                  _resetTimer(templateExercise.restPeriod);
                },
                validator: (value) => (value == null || value.isEmpty) ? 'Enter reps' : null,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteSet(exerciseIndex, setIndex),
            ),
          ],
        ),
        if (set.setNumber < templateExercise.sets)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Rest Period: ${templateExercise.restPeriod} seconds',
              style: const TextStyle(color: Colors.black, fontStyle: FontStyle.italic),
            ),
          ),
      ],
    );
  }

  Widget _buildAddSetButton(int exerciseIndex) {
    return TextButton.icon(
      onPressed: () => _addSet(exerciseIndex),
      icon: const Icon(Icons.add),
      label: const Text('Add Set'),
    );
  }

Widget _buildAddExerciseButton() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 16.0),
    child: ElevatedButton.icon(
      onPressed: _addExercise,
      icon: const Icon(Icons.add),
      label: const Text('Add Exercise'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      ),
    ),
  );
}

  Widget _buildTimer() {
    return Text(
      'Timer: $_timerSeconds.${(_timerMilliseconds / 100).floor()}s',
      style: TextStyle(
        color: _timerSeconds >= _currentExerciseRestPeriod ? Colors.red : Colors.black,
      ),
    );
  }
}