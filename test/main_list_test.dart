// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:timato/main.dart';
import 'package:timato/ui/main_list.dart';

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
}
