import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:whisker/main.dart';
import 'package:whisker/models/cat_state.dart';
import 'package:whisker/models/daily_task_log.dart';
import 'package:whisker/models/diary_entry.dart';
import 'package:whisker/models/hidden_message.dart';
import 'package:whisker/models/task_type.dart';
import 'package:whisker/providers/cat_provider.dart';

void main() {
  setUpAll(() async {
    // Initialize Hive in a temporary directory for unit testing
    final tempDir = Directory.systemTemp.createTempSync('whisker_test');
    Hive.init(tempDir.path);

    // Register all required Hive adapters for testing
    try {
      Hive.registerAdapter(CatStateAdapter());
      Hive.registerAdapter(DailyTaskLogAdapter());
      Hive.registerAdapter(HiddenMessageAdapter());
      Hive.registerAdapter(DiaryEntryAdapter());
    } catch (_) {
      // Adapters might already be registered in execution context
    }

    // Open the boxes needed by the providers
    await Hive.openBox<CatState>('catStateBox');
    await Hive.openBox<DailyTaskLog>('dailyTaskLogBox');
    await Hive.openBox<HiddenMessage>('hiddenMessageBox');
    await Hive.openBox<DiaryEntry>('diaryBox');

    // Seed test cat state
    final catStateBox = Hive.box<CatState>('catStateBox');
    if (catStateBox.isEmpty) {
      await catStateBox.put(
        'default_cat',
        CatState(
          id: 'default_cat',
          name: 'Whisker',
          bondLevel: 0,
          adoptedDate: DateTime.now(),
        ),
      );
    }
  });

  testWidgets('Whisker app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: WhiskerApp(),
      ),
    );

    // Wait for splash screen navigation timer and route transition to complete
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 850));

    // Verify that the title "Whisker" is shown on the home screen.
    expect(find.text('Whisker'), findsWidgets);
    
    // Verify that the task button icons are present (e.g. Feed button, etc.)
    expect(find.text('Feed'), findsOneWidget);
    expect(find.text('Play'), findsOneWidget);
    expect(find.text('Brush'), findsOneWidget);
    expect(find.text('Cuddle'), findsOneWidget);
  });

  testWidgets('Verify decay and streak reset logic on missed days', (WidgetTester tester) async {
    final catStateBox = Hive.box<CatState>('catStateBox');
    
    // Create a cat state with 50 bond level, accessories, last interaction 5 days ago, and streak 10
    final initialCat = CatState(
      id: 'decay_test_cat',
      name: 'DecayTester',
      bondLevel: 50,
      accessoriesUnlocked: ['Red Collar', 'Yellow Bell'],
      equippedAccessory: 'Red Collar',
      lastInteractionDate: DateTime.now().subtract(const Duration(days: 5)),
      currentStreak: 10,
      longestStreak: 12,
      adoptedDate: DateTime.now().subtract(const Duration(days: 10)),
    );
    await catStateBox.put('decay_test_cat', initialCat);

    // Instantiate notifier
    final container = ProviderContainer();
    final notifier = container.read(catProvider.notifier);
    
    // Override state to match initialCat
    notifier.state = initialCat;

    // Check decay
    notifier.checkForMissedDay();

    // Verify bondLevel dipped gently (-4 because 5 days difference -> 5 - 1 = 4 decay)
    expect(notifier.state.bondLevel, 46);
    // Verify accessories are intact
    expect(notifier.state.accessoriesUnlocked, contains('Red Collar'));
    expect(notifier.state.accessoriesUnlocked, contains('Yellow Bell'));
    expect(notifier.state.equippedAccessory, 'Red Collar');

    // Complete a task to trigger streak check
    // Yesterday is not active, so currentStreak should reset to 1
    await notifier.completeTask(TaskType.feed);

    expect(notifier.state.currentStreak, 1);
    // Longest streak remains 12
    expect(notifier.state.longestStreak, 12);
    // Bond level increased by +2
    expect(notifier.state.bondLevel, 48);
  });
}
