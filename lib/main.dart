import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:whisker/models/cat_state.dart';
import 'package:whisker/models/daily_task_log.dart';
import 'package:whisker/models/hidden_message.dart';
import 'package:whisker/models/diary_entry.dart';
import 'package:whisker/screens/splash_screen.dart';
import 'package:whisker/theme/app_theme.dart';
import 'package:whisker/services/notification_service.dart';

void main() async {
  // Ensure widget binding is initialized before calling native platforms/Hive init
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications
  await NotificationService().init();

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Register Hive TypeAdapters
  Hive.registerAdapter(CatStateAdapter());
  Hive.registerAdapter(DailyTaskLogAdapter());
  Hive.registerAdapter(HiddenMessageAdapter());
  Hive.registerAdapter(DiaryEntryAdapter());

  // Open Hive boxes
  final catStateBox = await Hive.openBox<CatState>('catStateBox');
  await Hive.openBox<DailyTaskLog>('dailyTaskLogBox');
  await Hive.openBox<HiddenMessage>('hiddenMessageBox');
  await Hive.openBox<DiaryEntry>('diaryBox');

  // Seed initial CatState if none exists
  if (catStateBox.isEmpty) {
    final initialCat = CatState(
      id: 'default_cat',
      name: 'Whisker',
      bondLevel: 0,
      accessoriesUnlocked: [],
      equippedAccessory: null,
      lastInteractionDate: null,
      currentStreak: 0,
      longestStreak: 0,
      adoptedDate: DateTime.now(),
    );
    await catStateBox.put('default_cat', initialCat);
  }

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
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
