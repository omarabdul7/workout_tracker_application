import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'my_app.dart';
import 'firebase_options.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    await dotenv.load(fileName: ".env");
    
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(const MyApp());
  } catch (e) {
    debugPrint('Error initializing app: $e');
    // You might want to show some error UI here
    runApp(const MyApp()); // Still run the app, but you might want to disable Firebase features
  }
}
 