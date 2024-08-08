import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// MyAppState
class MyAppState extends ChangeNotifier {
  bool isDarkMode = false;

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }
}

