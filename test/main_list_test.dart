import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timato/core/db.dart';

import 'package:timato/main.dart';
import 'package:timato/ui/main_list.dart';
import 'package:timato/core/event.dart';
import 'package:timato/core/event_repository.dart';

void main() {
  testWidgets('Event Listview Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(
      home: ToDoList(),
    ));

    // Verify that both events are on the list
    //expect(find.byType(ReorderableListView), findsOneWidget);
    expect(find.text('背单词'), findsOneWidget);
    expect(find.text('写作文'), findsOneWidget);
    expect(find.text('test'), findsNothing);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Chinese'), findsOneWidget);
    expect(find.text('2029'), findsWidgets);
  });


  testWidgets('Event List Expansion Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(
      home: ToDoList(),
    ));

    await tester.tap(find.text('背单词'));
    await tester.pump();

    expect(find.text('sub1'),findsOneWidget);
    expect(find.text('sub2'),findsNothing);

    await tester.tap(find.text('写作文'));
    await tester.pump();

    expect(find.text('sub1'),findsWidgets);
    expect(find.text('sub2'),findsNothing);

    }
  );

  testWidgets('My Tasks Page - DB', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(
      home: ToDoList(),
    ));
    EventRepository databaseHelper = EventRepository();
    Event taskTester = new Event(taskName:'写代码tester', isUnplanned: 1);
    await databaseHelper.insertEvent(taskTester);
    // Verify that both events are on the list
    //expect(find.byType(ReorderableListView), findsOneWidget);
    expect(find.text('背单词'), findsOneWidget);
    expect(find.text('写作文'), findsOneWidget);
    expect(find.text('test'), findsNothing);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Chinese'), findsOneWidget);
    expect(find.text('2029'), findsWidgets);
    expect(find.text('写代码tester'), findsOneWidget);
    expect(find.byIcon(Icons.warning), findsOneWidget);
  });
}
