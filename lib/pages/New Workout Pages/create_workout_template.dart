import 'package:flutter/material.dart';
import '/models/workout.dart';
import '/models/exercise.dart';
import '/services/workout_service.dart';


class CreateWorkoutTemplate extends StatefulWidget {
  const CreateWorkoutTemplate({Key? key}) : super(key: key);

  @override
  CreateWorkoutTemplateState createState() => CreateWorkoutTemplateState();
}

class CreateWorkoutTemplateState extends State<CreateWorkoutTemplate> {
  final _formKey = GlobalKey<FormState>();
  String _workoutName = '';
  final List<Exercise> _exercises = [];

  final _exerciseController = TextEditingController();
  final _setsController = TextEditingController();
  final _restPeriodController = TextEditingController();

void _addExercise() {
  final exerciseName = _exerciseController.text.trim();
  final setsText = _setsController.text.trim();
  final restPeriodText = _restPeriodController.text.trim();

  if (exerciseName.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter an exercise name')),
    );
    return;
  }

  final sets = int.tryParse(setsText);
  if (sets == null || sets <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter a valid number of sets')),
    );
    return;
  }

  final restPeriod = int.tryParse(restPeriodText);
  if (restPeriod == null || restPeriod <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter a valid rest period')),
    );
    return;
  }

  setState(() {
    _exercises.add(Exercise(name: exerciseName, sets: sets, restPeriod: restPeriod));
    _exerciseController.clear();
    _setsController.clear();
    _restPeriodController.clear();
  });
}


  void _saveWorkout() {
    if (_formKey.currentState!.validate() && _exercises.isNotEmpty) {
      final workout = Workout(
        name: _workoutName,
        exercises: _exercises,
        createdAt: DateTime.now(),
      );

      WorkoutService().addWorkout(workout).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workout saved successfully')),
        );
        Navigator.pop(context);
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving workout: $error')),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and add at least one exercise')),
      );
    }
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Create New Workout'),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Workout Name'),
              onChanged: (value) {
                setState(() {
                  _workoutName = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a workout name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _exerciseController,
                    decoration: const InputDecoration(labelText: 'Exercise Name'),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 80,
                  child: TextFormField(
                    controller: _setsController,
                    decoration: const InputDecoration(labelText: 'Sets'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 80,
                  child: TextFormField(
                    controller: _restPeriodController,
                    decoration: const InputDecoration(labelText: 'Rest (s)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addExercise,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Exercises',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _exercises.length,
                itemBuilder: (context, index) {
                  final exercise = _exercises[index];
                  return ListTile(
                    title: Text('${exercise.name} (${exercise.sets} sets, ${exercise.restPeriod} sec rest)'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _exercises.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _saveWorkout,
              child: const Text('Save Workout'),
            ),
          ],
        ),
      ),
    ),
  );
}


  @override
  void dispose() {
    _exerciseController.dispose();
    _setsController.dispose();
    _restPeriodController.dispose();
    super.dispose();
  }
}
