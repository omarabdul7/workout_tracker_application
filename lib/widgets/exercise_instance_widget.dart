import 'package:flutter/material.dart';
import '/models/exercise.dart';
import '/models/workout_instance.dart';
import 'set_row_widget.dart';

class ExerciseInstanceWidget extends StatelessWidget {
  final ExerciseInstance exercise;
  final int exerciseIndex;
  final Exercise templateExercise;
  final WorkoutInstance? lastWorkoutInstance;
  final Function(int, int) onMoveExercise;
  final Function(int) onDeleteExercise;
  final Function(int) onAddSet;
  final Function(int, int) onDeleteSet;
  final VoidCallback onSetChanged;

  const ExerciseInstanceWidget({
    Key? key,
    required this.exercise,
    required this.exerciseIndex,
    required this.templateExercise,
    required this.lastWorkoutInstance,
    required this.onMoveExercise,
    required this.onDeleteExercise,
    required this.onAddSet,
    required this.onDeleteSet,
    required this.onSetChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: const Color.fromARGB(255, 241, 246, 249),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildExerciseHeader(),
            const SizedBox(height: 8),
            _buildPreviousWorkoutInfo(),
            ...exercise.sets.map((set) => SetRowWidget(
              set: set,
              exerciseIndex: exerciseIndex,
              templateExercise: templateExercise,
              onDeleteSet: onDeleteSet,
              onSetChanged: onSetChanged,
            )).toList(),
            _buildAddSetButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseHeader() {
    return Row(
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
              onPressed: exerciseIndex > 0 ? () => onMoveExercise(exerciseIndex, exerciseIndex - 1) : null,
            ),
            IconButton(
              icon: const Icon(Icons.arrow_downward),
              onPressed: () => onMoveExercise(exerciseIndex, exerciseIndex + 1),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => onDeleteExercise(exerciseIndex),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPreviousWorkoutInfo() {
    final lastExerciseInstance = lastWorkoutInstance?.exercises.firstWhere(
      (e) => e.name == exercise.name,
      orElse: () => ExerciseInstance(name: exercise.name, sets: []),
    );

    if (lastExerciseInstance == null || lastExerciseInstance.sets.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Previous Workout', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...lastExerciseInstance.sets.map((set) => Padding(
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

  Widget _buildAddSetButton() {
    return TextButton(
      onPressed: () => onAddSet(exerciseIndex),
      child: const Text('Add Set'),
    );
  }
}