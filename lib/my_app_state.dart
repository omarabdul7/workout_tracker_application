import 'package:flutter/material.dart';

// MyAppState
class MyAppState extends ChangeNotifier {
  bool isDarkMode = false;

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }
}

