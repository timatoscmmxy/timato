import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timato/core/db.dart';

import 'package:timato/main.dart';
import 'package:timato/ui/main_list.dart';
import 'package:timato/core/event.dart';
import 'package:timato/core/event_repository.dart';
import 'dart:developer' as developer;

void main() {
  testWidgets('Event Listview Test', (WidgetTester tester) async {
    // EventRepository databaseHelper = EventRepository();
    // Event taskTester = new Event(taskName:'写代码tester', isUnplanned: 1);
    // databaseHelper.insertEvent(taskTester);
    // Build our app and trigger a frame.
    // WidgetsFlutterBinding.ensureInitialized();

    // EventRepository databaseHelper = new EventRepository();
    // Event event = new Event(taskName: '打电话');
    // int id = await databaseHelper.insertEvent(event);

    await tester.pumpWidget(MaterialApp(
      home: MyTask(),
    ));


    await tester.pump(new Duration(seconds: 2));
    await tester.pumpAndSettle();

    // EventRepository databaseHelper = EventRepository();
    // Event taskTester = new Event(taskName:'写代码tester', isUnplanned: 1);
    // databaseHelper.insertEvent(taskTester);

    // expect(find.byType(IconButton), findsWidgets);
    // Verify that both events are on the list
    //expect(find.byType(ReorderableListView), findsOneWidget);
    expect(find.text('打电话'), findsWidgets);
    // expect(find.byIcon(Icons.warning), findsWidgets);
    // expect(find.text('My Tasks'), findsOneWidget);
    // expect(find.text('背单词2'), findsWidgets);
    // expect(find.text('test'), findsNothing);
    // expect(find.text('English'), findsWidgets);
    // expect(find.text('Chinese'), findsWidgets);
    // expect(find.text('2029'), findsWidgets);
  });


  // testWidgets('Event List Expansion Test', (WidgetTester tester) async {
  //   // Build our app and trigger a frame.
  //   await tester.pumpWidget(MaterialApp(
  //     home: MyTask(),
  //   ));

  //   await tester.tap(find.text('背单词1'));
  //   await tester.pump();

  //   expect(find.text('sub1'),findsOneWidget);
  //   expect(find.text('sub2'),findsNothing);

  //   await tester.tap(find.text('背单词3'));
  //   await tester.pump();

  //   expect(find.text('sub1'),findsOneWidget);
  //   expect(find.text('sub2'),findsNothing);

  //   }
  // );

  // testWidgets('My Tasks Page - DB', (WidgetTester tester) async {
  //   // Build our app and trigger a frame.
  //   await tester.pumpWidget(MaterialApp(
  //     home: MyTask(),
  //   ));
  //   EventRepository databaseHelper = EventRepository();
  //   Event taskTester = new Event(taskName:'写代码tester', isUnplanned: 1);
  //   await databaseHelper.insertEvent(taskTester);
  //   // Verify that both events are on the list
  //   //expect(find.byType(ReorderableListView), findsOneWidget);
  //   // expect(find.text('背单词'), findsOneWidget);
  //   // expect(find.text('写作文'), findsOneWidget);
  //   // expect(find.text('test'), findsNothing);
  //   // expect(find.text('English'), findsOneWidget);
  //   // expect(find.text('Chinese'), findsOneWidget);
  //   // expect(find.text('2029'), findsWidgets);
  //   expect(find.text('写代码tester'), findsOneWidget);
  //   expect(find.byIcon(Icons.warning), findsOneWidget);
  // });

  testWidgets('Natigator test', (WidgetTester tester) async {
    // EventRepository databaseHelper = EventRepository();
    // Event taskTester = new Event(taskName:'写代码tester', isUnplanned: 1);
    // databaseHelper.insertEvent(taskTester);
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(
      home: MyTask(),
    ));

    await tester.tap(find.byType(IconButton));

    expect(find.text('My Tasks'), findsOneWidget);

    // await tester.tap(find.text("Today's Task"));

    // expect(find.byIcon(Icons.settings), findsOneWidget);
    
  });
}
