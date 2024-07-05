import 'package:flutter/material.dart';
import '/models/workout.dart';
import 'dart:async';
import '/models/workout_instance.dart';
import '/services/workout_instance_service.dart';

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

  @override
  void initState() {
    super.initState();
    _loadDataFuture = _loadLastWorkoutInstance();
    _startTimer();
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

  void _moveExerciseUp(int index) {
    if (index > 0) {
      setState(() {
        final temp = _exerciseInstances[index];
        _exerciseInstances[index] = _exerciseInstances[index - 1];
        _exerciseInstances[index - 1] = temp;
      });
    }
  }

  void _moveExerciseDown(int index) {
    if (index < _exerciseInstances.length - 1) {
      setState(() {
        final temp = _exerciseInstances[index];
        _exerciseInstances[index] = _exerciseInstances[index + 1];
        _exerciseInstances[index + 1] = temp;
      });
    }
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

  void _resetTimer() {
    setState(() {
      _timerSeconds = 0;
      _timerMilliseconds = 0;
    });
  }


@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(widget.workout.name),
      actions: [
        TextButton(
          onPressed: _saveWorkoutInstance,
          child: const Text(
            'Finish',
            style: TextStyle(color: Colors.green),
          ),
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
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          ..._exerciseInstances.map((exercise) {
                            final exerciseIndex = _exerciseInstances.indexOf(exercise);
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              color: const Color.fromARGB(255, 241, 246, 249),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          exercise.name,
                                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.arrow_upward),
                                              onPressed: exerciseIndex > 0
                                                  ? () => _moveExerciseUp(exerciseIndex)
                                                  : null,
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.arrow_downward),
                                              onPressed: exerciseIndex < _exerciseInstances.length - 1
                                                  ? () => _moveExerciseDown(exerciseIndex)
                                                  : null,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    if (_lastWorkoutInstance != null) ...[
                                      Text(
                                        'Previous',
                                        style: TextStyle(color: Colors.grey[700]),
                                      ),
                                      const SizedBox(height: 8),
                                      ..._lastWorkoutInstance!.exercises
                                          .where((e) => e.name == exercise.name)
                                          .expand((e) => e.sets.map((set) => Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                                child: Text('Set ${set.setNumber}: ${set.weight} lb x ${set.reps}'),
                                              ))),
                                      const Divider(thickness: 1),
                                      const SizedBox(height: 8),
                                    ],
                                    ...exercise.sets.map((set) => Row(
                                          children: [
                                            Expanded(
                                              child: TextFormField(
                                                decoration: InputDecoration(labelText: 'Set ${set.setNumber} - lbs'),
                                                keyboardType: TextInputType.number,
                                                initialValue: set.weight.toString(),
                                                onChanged: (value) {
                                                  set.weight = double.tryParse(value) ?? 0.0;
                                                  _resetTimer();
                                                },
                                                validator: (value) {
                                                  if (value == null || value.isEmpty) {
                                                    return 'Enter weight';
                                                  }
                                                  return null;
                                                },
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
                                                  _resetTimer();
                                                },
                                                validator: (value) {
                                                  if (value == null || value.isEmpty) {
                                                    return 'Enter reps';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                          ],
                                        )).toList(),
                                    TextButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          exercise.sets.add(SetDetails(
                                            setNumber: exercise.sets.length + 1,
                                            weight: 0.0,
                                            reps: 0,
                                          ));
                                          _resetTimer();
                                        });
                                      },
                                      icon: const Icon(Icons.add),
                                      label: const Text('Add Set'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                          TextButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  String newExerciseName = '';
                                  return AlertDialog(
                                    title: const Text('Add New Exercise'),
                                    content: TextFormField(
                                      decoration: const InputDecoration(labelText: 'Exercise Name'),
                                      onChanged: (value) {
                                        newExerciseName = value;
                                      },
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          if (newExerciseName.isNotEmpty) {
                                            setState(() {
                                              _exerciseInstances.add(ExerciseInstance(
                                                name: newExerciseName,
                                                sets: [SetDetails(setNumber: 1, weight: 0.0, reps: 0)],
                                              ));
                                            });
                                            Navigator.of(context).pop();
                                          }
                                        },
                                        child: const Text('Add'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Cancel'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add Exercises'),
                            style: TextButton.styleFrom(foregroundColor: Colors.blue),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center( // Center widget added here
                  child: Column(
                    children: [
                      Text(
                        '$_timerSeconds.${(_timerMilliseconds / 100).floor()} seconds',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                    ],
                  ),
                ),
              ],
            ),
          );
        }
      },
    ),
  );
}
}