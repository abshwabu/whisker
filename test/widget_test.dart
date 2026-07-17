import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whisker/main.dart';

void main() {
  testWidgets('Whisker app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: WhiskerApp(),
      ),
    );

    // Verify that the title "Whisker" is shown on the home screen.
    expect(find.text('Whisker'), findsWidgets);
    expect(find.byIcon(Icons.pets), findsOneWidget);
  });
}
