import 'package:flutter/material.dart';
import '/models/exercise.dart';
import '/models/workout_instance.dart';

class SetRowWidget extends StatelessWidget {
  final SetDetails set;
  final int exerciseIndex;
  final Exercise templateExercise;
  final Function(int, int) onDeleteSet;
  final VoidCallback onSetChanged;
  final ThemeData theme;

  const SetRowWidget({
    super.key,
    required this.set,
    required this.exerciseIndex,
    required this.templateExercise,
    required this.onDeleteSet,
    required this.onSetChanged,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = theme.brightness == Brightness.dark 
        ? Colors.transparent
        : const Color.fromARGB(255, 247, 250, 252); 

    final textColor = theme.brightness == Brightness.dark
        ? Colors.white
        : const Color(0xFF192428);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? const Color.fromARGB(0, 255, 255, 255)
              : const Color(0xFFE0E0E0),
        ),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Set ${set.setNumber} - lbs',
                    labelStyle: TextStyle(
                      color: theme.brightness == Brightness.dark
                          ? Colors.white70
                          : const Color(0xFF414C50),
                    ),
                    filled: true,
                    fillColor: theme.brightness == Brightness.dark
                        ? const Color(0xFF1E1E1E)
                        : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: theme.brightness == Brightness.dark
                            ? Colors.transparent
                            : const Color(0xFFE0E0E0),
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  keyboardType: TextInputType.number,
                  initialValue: set.weight.toString(),
                  style: TextStyle(color: textColor),
                  onChanged: (value) {
                    set.weight = double.tryParse(value) ?? 0.0;
                    onSetChanged();
                  },
                  validator: (value) => (value == null || value.isEmpty) ? 'Enter weight' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Reps',
                    labelStyle: TextStyle(
                      color: theme.brightness == Brightness.dark
                          ? Colors.white70
                          : const Color(0xFF414C50),
                    ),
                    filled: true,
                    fillColor: theme.brightness == Brightness.dark
                        ? const Color(0xFF1E1E1E)
                        : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: theme.brightness == Brightness.dark
                            ? Colors.transparent
                            : const Color(0xFFE0E0E0),
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  keyboardType: TextInputType.number,
                  initialValue: set.reps.toString(),
                  style: TextStyle(color: textColor),
                  onChanged: (value) {
                    set.reps = int.tryParse(value) ?? 0;
                    onSetChanged();
                  },
                  validator: (value) => (value == null || value.isEmpty) ? 'Enter reps' : null,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete, 
                  color: theme.colorScheme.error,
                ),
                onPressed: () => onDeleteSet(exerciseIndex, set.setNumber - 1),
              ),
            ],
          ),
          if (set.setNumber < templateExercise.sets)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Rest: ${templateExercise.restPeriod} seconds',
                style: TextStyle(
                  color: theme.brightness == Brightness.dark
                      ? const Color(0xFFF5F9FC)
                      : const Color(0xFF414C50),
                  fontStyle: FontStyle.italic,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}