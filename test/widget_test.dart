import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:whisker/main.dart';
import 'package:whisker/models/cat_state.dart';
import 'package:whisker/models/daily_task_log.dart';
import 'package:whisker/models/diary_entry.dart';
import 'package:whisker/models/hidden_message.dart';

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

    // Rebuild the frame to process animations and state
    await tester.pump();

    // Verify that the title "Whisker" is shown on the home screen.
    expect(find.text('Whisker'), findsWidgets);
    
    // Verify that the task button icons are present (e.g. Feed button, etc.)
    expect(find.text('Feed'), findsOneWidget);
    expect(find.text('Play'), findsOneWidget);
    expect(find.text('Brush'), findsOneWidget);
    expect(find.text('Cuddle'), findsOneWidget);
  });
}
