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
    
    // Color palette from the provided colors
    // #39ace7 - Light blue (57,172,231) - Only for light mode accent
    // #0784b5 - Medium blue (7,132,181) 
    // #414c50 - Gray blue (65,76,80)
    // #2d383c - Dark gray blue (45,56,60)
    // #192428 - Darkest blue (25,36,40) - Primary for light mode
    
    // Primary colors
    final primaryColor = isDarkMode ? const Color(0xFF303030) : const Color(0xFF192428);
    final secondaryColor = isDarkMode ? const Color(0xFF505050) : const Color(0xFF2D383C);
    final accentColor = isDarkMode ? const Color(0xFF757575) : const Color(0xFF0784B5);
    
    // Background and surface colors
    final backgroundColor = isDarkMode ? Colors.black : const Color(0xFFF5F9FC);
    final surfaceColor = isDarkMode ? const Color(0xFF121212) : Colors.white;
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    
    // Text and content colors
    final onPrimaryColor = Colors.white;
    final onSurfaceColor = isDarkMode ? Colors.white : const Color(0xFF192428);
    final onBackgroundColor = isDarkMode ? Colors.white : const Color(0xFF192428);
    
    final colorScheme = ColorScheme(
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      primary: primaryColor,
      onPrimary: onPrimaryColor,
      secondary: secondaryColor,
      onSecondary: Colors.white,
      surface: surfaceColor,
      onSurface: onSurfaceColor,
      background: backgroundColor,
      onBackground: onBackgroundColor,
      error: isDarkMode ? const Color(0xFFCF6679) : const Color(0xFFB00020),
      onError: Colors.white,
      tertiary: accentColor,
      onTertiary: Colors.white,
    );

    return baseTheme.copyWith(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundColor,
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: onBackgroundColor,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: onBackgroundColor,
          letterSpacing: -0.25,
        ),
        displaySmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: onBackgroundColor,
        ),
        headlineMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: onBackgroundColor,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: onBackgroundColor,
          letterSpacing: 0.15,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: onBackgroundColor,
          letterSpacing: 0.25,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: isDarkMode ? Colors.white70 : const Color(0xFF414C50),
          letterSpacing: 0.4,
        ),
      ),
      cardTheme: CardTheme(
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: isDarkMode ? 0 : 2,
        shadowColor: isDarkMode ? Colors.black : Colors.black.withOpacity(0.1),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        selectedItemColor: isDarkMode ? Colors.white : accentColor,
        unselectedItemColor: isDarkMode ? Colors.grey.shade600 : const Color(0xFF414C50),
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        elevation: 8,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDarkMode ? const Color(0xFF2A2A2A) : Colors.grey.shade100,
        disabledColor: Colors.grey.withOpacity(0.2),
        selectedColor: isDarkMode ? Colors.grey.shade700 : accentColor.withOpacity(0.2),
        secondarySelectedColor: isDarkMode ? Colors.grey.shade500 : accentColor,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        labelStyle: TextStyle(
          color: onSurfaceColor,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: TextStyle(
          color: isDarkMode ? Colors.white : accentColor,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: isDarkMode ? Colors.grey.shade300 : accentColor,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: isDarkMode ? Colors.grey.shade300 : accentColor,
          side: BorderSide(color: isDarkMode ? Colors.grey.shade500 : accentColor),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      iconTheme: IconThemeData(
        color: onSurfaceColor,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: isDarkMode ? Colors.grey.shade400 : accentColor,
        linearTrackColor: isDarkMode ? Colors.grey.shade800 : accentColor.withOpacity(0.1),
        circularTrackColor: isDarkMode ? Colors.grey.shade800 : accentColor.withOpacity(0.1),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDarkMode ? Colors.grey.shade500 : accentColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: TextStyle(
          color: isDarkMode ? Colors.white70 : const Color(0xFF414C50),
        ),
        hintStyle: TextStyle(
          color: isDarkMode ? Colors.white60 : Colors.grey.shade600,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: isDarkMode ? Colors.white24 : Colors.grey.shade300,
        thickness: 1,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300;
          }
          return isDarkMode ? Colors.grey.shade600 : accentColor;
        }),
        checkColor: MaterialStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return isDarkMode ? Colors.grey.shade400 : accentColor;
          }
          return isDarkMode ? Colors.grey.shade700 : Colors.grey.shade50;
        }),
        trackColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return isDarkMode ? Colors.grey.shade600 : accentColor.withOpacity(0.5);
          }
          return isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300;
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: isDarkMode ? Colors.grey.shade400 : accentColor,
        inactiveTrackColor: isDarkMode ? Colors.grey.shade800 : accentColor.withOpacity(0.3),
        thumbColor: isDarkMode ? Colors.grey.shade300 : accentColor,
        overlayColor: isDarkMode ? Colors.grey.shade700.withOpacity(0.2) : accentColor.withOpacity(0.2),
        valueIndicatorColor: isDarkMode ? Colors.grey.shade700 : accentColor,
        valueIndicatorTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: isDarkMode ? Colors.grey.shade800 : primaryColor,
        foregroundColor: Colors.white,
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