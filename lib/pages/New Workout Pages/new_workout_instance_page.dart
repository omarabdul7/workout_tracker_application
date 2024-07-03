import 'package:flutter/material.dart';
import '/models/workout.dart';
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

  @override
  void initState() {
    super.initState();
    for (var exercise in widget.workout.exercises) {
      final sets = List.generate(exercise.sets, (index) => SetDetails(setNumber: index + 1, weight: 0.0, reps: 0));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workout.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ..._exerciseInstances.map((exercise) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  ...exercise.sets.map((set) => Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(labelText: 'Set ${set.setNumber} - Weight'),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            set.weight = double.tryParse(value) ?? 0.0;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a weight';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(labelText: 'Reps'),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            set.reps = int.tryParse(value) ?? 0;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter reps';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  )).toList(),
                  const Divider(),
                ],
              )).toList(),
              ElevatedButton(
                onPressed: _saveWorkoutInstance,
                child: const Text('Save Workout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
