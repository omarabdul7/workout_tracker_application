import 'package:flutter/material.dart';
import '/models/exercise.dart';
import '/models/workout_instance.dart';
import 'set_row_widget.dart';

class ExerciseInstanceWidget extends StatelessWidget {
  final ExerciseInstance exercise;
  final Function(int) onResetTimer;
  final int exerciseIndex;
  final Exercise templateExercise;
  final WorkoutInstance? lastWorkoutInstance;
  final Function(int, int) onMoveExercise;
  final Function(int) onDeleteExercise;
  final Function(int) onAddSet;
  final Function(int, int) onDeleteSet;
  final VoidCallback onSetChanged;
  final ThemeData theme;

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
    required this.onResetTimer,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildExerciseHeader(),
            const SizedBox(height: 16),
            _buildPreviousWorkoutInfo(),
            ...exercise.sets.map((set) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: SetRowWidget(
                set: set,
                exerciseIndex: exerciseIndex,
                templateExercise: templateExercise,
                onDeleteSet: onDeleteSet,
                onSetChanged: onSetChanged,
                theme: theme,
              ),
            )).toList(),
            _buildAddSetButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseHeader() {
    final arrowColor = theme.brightness == Brightness.light ? theme.colorScheme.onSurface : theme.colorScheme.primary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          exercise.name,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_upward, color: arrowColor),
              onPressed: exerciseIndex > 0 ? () => onMoveExercise(exerciseIndex, exerciseIndex - 1) : null,
            ),
            IconButton(
              icon: Icon(Icons.arrow_downward, color: arrowColor),
              onPressed: () => onMoveExercise(exerciseIndex, exerciseIndex + 1),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: theme.colorScheme.error), 
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
        Text(
          'Previous Workout',
          style: TextStyle(
            color: theme.brightness == Brightness.dark
                ? theme.colorScheme.secondary
                : const Color(0xFF34A4FC), 
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),
        ...lastExerciseInstance.sets.map((set) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(
            'Set ${set.setNumber}: ${set.weight} lb x ${set.reps} reps',
            style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
          ),
        )),
        Divider(thickness: 1, color: theme.colorScheme.onSurface.withOpacity(0.1)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAddSetButton() {
    return TextButton.icon(
      onPressed: () => onAddSet(exerciseIndex),
      icon: Icon(
        Icons.add,
        color: theme.brightness == Brightness.light
            ? const Color(0xFF2C4C60) 
            : theme.colorScheme.primary, 
      ),
      label: Text(
        'Add Set',
        style: TextStyle(
          color: theme.brightness == Brightness.light
              ? const Color(0xFF2C4C60) 
              : theme.colorScheme.onPrimary, 
          fontWeight: FontWeight.bold,
          fontSize: 14, 
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8), 
        backgroundColor: Colors.transparent, 
        side: BorderSide.none,
      ),
    );
  }
}
