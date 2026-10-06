// test/widget_test.dart
//
// Basic smoke test that the app builds.

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('App builds without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartQueueApp());
    expect(find.text('Smart Queue AI'), findsWidgets);
  });
}
