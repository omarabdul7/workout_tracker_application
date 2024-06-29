import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'models/workout.dart';

class MyAppState extends ChangeNotifier {
  WordPair _current = WordPair.random();
  WordPair get current => _current;

  void getNext() {
    _current = WordPair.random();
    notifyListeners();
  }

  final List<WordPair> _favorites = <WordPair>[];
  List<WordPair> get favorites => _favorites;

  void toggleFavorite() {
    if (_favorites.contains(current)) {
      _favorites.remove(current);
    } else {
      _favorites.add(current);
    }
    notifyListeners();
  }

  final List<Workout> _workouts = <Workout>[];
  List<Workout> get workouts => _workouts;

  void addWorkout(Workout workout) {
    _workouts.add(workout);
    notifyListeners();
  }
}
