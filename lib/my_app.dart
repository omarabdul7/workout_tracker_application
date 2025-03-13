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
            routes: {
              '/home': (context) {
                final args = ModalRoute.of(context)?.settings.arguments;
                return MyHomePage(initialIndex: args is int ? args : 0);
              },
            },
          );
        },
      ),
    );
  }

  ThemeData _buildTheme(bool isDarkMode) {
    final baseTheme = isDarkMode ? ThemeData.dark() : ThemeData.light();
    
    // Define more contrasting colors while keeping the same color scheme
    final primaryColor = isDarkMode ? const Color(0xFF1F1F1F) : const Color(0xFF2C4C60);
    final secondaryColor = isDarkMode ? const Color(0xFF3D85C6) : const Color(0xFF5B9BD5);
    final surfaceColor = isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFF5F9FC);
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final onPrimaryColor = Colors.white;
    final onSurfaceColor = isDarkMode ? Colors.white : const Color(0xFF2C4C60);
    
    final colorScheme = ColorScheme.fromSeed(
      seedColor: secondaryColor,
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      primary: primaryColor,
      onPrimary: onPrimaryColor,
      secondary: secondaryColor,
      onSecondary: Colors.white,
      surface: surfaceColor,
      onSurface: onSurfaceColor,
      background: backgroundColor,
      onBackground: isDarkMode ? Colors.white : Colors.black,
    );

    return baseTheme.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundColor,
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
          color: isDarkMode ? Colors.white : const Color(0xFF2C2C2C),
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: isDarkMode ? Colors.white70 : Colors.black87,
        ),
      ),
      cardTheme: CardTheme(
        color: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 4,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: primaryColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: isDarkMode ? Colors.grey.shade400 : Colors.white.withOpacity(0.7),
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
      ),
      appBarTheme: AppBarTheme(
        color: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceColor,
        disabledColor: Colors.grey.withOpacity(0.2),
        selectedColor: secondaryColor.withOpacity(0.2),
        secondarySelectedColor: secondaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        labelStyle: TextStyle(
          color: isDarkMode ? Colors.white : const Color(0xFF2C4C60),
        ),
        secondaryLabelStyle: TextStyle(
          color: secondaryColor,
          fontWeight: FontWeight.bold,
        ),
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      iconTheme: IconThemeData(
        color: isDarkMode ? Colors.white : primaryColor,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: secondaryColor,
        linearTrackColor: secondaryColor.withOpacity(0.1),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final int initialIndex;
  
  const MyHomePage({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return const HomePage();
      case 1:
        return const HistoryPage();
      case 2:
        return const NewWorkoutPage();
      case 3:
        return const SettingsPage();
      default:
        return const HomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: _getPage(_selectedIndex),
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