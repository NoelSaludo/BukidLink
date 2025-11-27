import 'package:flutter/material.dart';
import 'App.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load environment variables from .env (optional but required for CloudinaryService)
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // Handle error if .env file is missing or cannot be read
    debugPrint('Error loading .env file: $e');
  }
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const App());
}
