import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_tracker_application/my_app_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: appState.isDarkMode,
            onChanged: (bool value) {
              appState.toggleTheme();
            },
          ),
        ],
      ),
    );
  }
}