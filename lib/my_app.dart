import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/home_page.dart';
import 'my_app_state.dart';
import 'pages/history_page.dart';
import 'pages/new_workout_page.dart';
import 'pages/settings_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: Consumer<MyAppState>(
        builder: (context, appState, child) {
          return MaterialApp(
            title: 'Workout Tracker',
            theme: _buildTheme(appState.isDarkMode),
            home: const MyHomePage(),
          );
        },
      ),
    );
  }

ThemeData _buildTheme(bool isDarkMode) {
  final baseTheme = isDarkMode ? ThemeData.dark() : ThemeData.light();
  final colorScheme = ColorScheme.fromSeed(
    seedColor: const Color.fromARGB(255, 241, 246, 249),
    brightness: isDarkMode ? Brightness.dark : Brightness.light,
  );

  return baseTheme.copyWith(
    useMaterial3: true,
    colorScheme: colorScheme.copyWith(
      primary: isDarkMode ? Colors.grey[900]: const Color.fromARGB(255, 241, 246, 249),
      onPrimary: isDarkMode ? Colors.white : Colors.black,
      background: isDarkMode ? Colors.black : Colors.white,
      surface: isDarkMode ? Colors.grey[900] : const Color(0xFF2C4C60),
      onSurface: isDarkMode ? Colors.white : Colors.black,
    ),
    scaffoldBackgroundColor: isDarkMode ? Colors.black : Colors.white,
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: isDarkMode ? Colors.white : Colors.black,
      ),
      displayMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: isDarkMode ? Colors.white : Colors.black,
      ),
      displaySmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: isDarkMode ? Colors.white : Colors.black,
      ),
      headlineMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: isDarkMode ? Colors.white : Colors.black,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: isDarkMode ? Colors.white : Colors.black,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: isDarkMode ? Colors.white : Colors.black,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: isDarkMode ? Colors.white70 : Colors.black87,
      ),
    ),
    cardTheme: CardTheme(
      color: isDarkMode 
          ? Colors.grey[800] 
          : const Color.fromARGB(255, 241, 246, 249),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 4,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: isDarkMode ? Colors.grey[900] : const Color(0xFF2C4C60),
      selectedItemColor: Colors.white,
      unselectedItemColor: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
      selectedLabelStyle: const TextStyle(fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
    ),
    appBarTheme: AppBarTheme(
      color: isDarkMode ? Colors.black : Colors.white,
      foregroundColor: isDarkMode ? Colors.white : Colors.black,
    ),
  );
}
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    HistoryPage(),
    NewWorkoutPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: Container(
        color: theme.bottomNavigationBarTheme.backgroundColor,
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center),
              label: 'New Workout',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor,
          unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor,
          backgroundColor: Colors.transparent,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }
}