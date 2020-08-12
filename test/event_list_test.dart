import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timato/ui/basics.dart';

import 'package:timato/ui/event_detail_page.dart';

void main() {
  testWidgets('Event List Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(
      home: EventList(),
    ));

    // Verify that both events are on the list
    //expect(find.byType(ReorderableListView), findsOneWidget);
    expect(find.text('背单词'), findsOneWidget);
    expect(find.text('sub1'), findsOneWidget);
    expect(find.text('High'), findsOneWidget);
    expect(find.text('Chinese'), findsOneWidget);
    expect(find.byIcon(Icons.label_outline), findsOneWidget);
    expect(find.byIcon(Icons.brightness_1), findsOneWidget);
    expect(find.byIcon(Icons.timer), findsOneWidget);
    expect(find.byIcon(Icons.subject), findsOneWidget);
    expect(find.byType(IconButton), findsWidgets);
    expect(find.byType(FloatingRaisedButton), findsOneWidget);
  });}