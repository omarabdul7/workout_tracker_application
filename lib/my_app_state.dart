import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'models/workout.dart';

class MyAppState extends ChangeNotifier {


  final List<Workout> _workouts = <Workout>[];
  List<Workout> get workouts => _workouts;

  void addWorkout(Workout workout) {
    _workouts.add(workout);
    notifyListeners();
  }
}
