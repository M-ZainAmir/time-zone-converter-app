import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_one_converter/main.dart';

void main() {
  testWidgets('WorldTimeApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const WorldTimeApp());
    // Verify the app renders without throwing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
