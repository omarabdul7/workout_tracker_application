import 'package:flutter/material.dart';
import '/models/exercise.dart';
import '/models/workout_instance.dart';


class SetRowWidget extends StatelessWidget {
  final SetDetails set;
  final int exerciseIndex;
  final Exercise templateExercise;
  final Function(int, int) onDeleteSet;
  final VoidCallback onSetChanged;

  const SetRowWidget({
    Key? key,
    required this.set,
    required this.exerciseIndex,
    required this.templateExercise,
    required this.onDeleteSet,
    required this.onSetChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  onSetChanged();
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
                  onSetChanged();
                },
                validator: (value) => (value == null || value.isEmpty) ? 'Enter reps' : null,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => onDeleteSet(exerciseIndex, set.setNumber - 1),
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
}