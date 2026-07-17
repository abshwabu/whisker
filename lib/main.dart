import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:whisker/screens/home_screen.dart';
import 'package:whisker/theme/app_theme.dart';

void main() async {
  // Ensure widget binding is initialized before calling native platforms/Hive init
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Run the app within a ProviderScope for Riverpod state management
  runApp(
    const ProviderScope(
      child: WhiskerApp(),
    ),
  );
}

class WhiskerApp extends StatelessWidget {
  const WhiskerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Whisker',
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
