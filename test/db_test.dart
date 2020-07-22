// import 'package:flutter_test/flutter_test.dart';
// @Skip("sqflite cannot run on the machine.")
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:test/test.dart';
import 'package:timato/core/event.dart';
import 'package:timato/core/event_repository.dart';

import 'dart:io';
// import "package:test/test.dart";
import 'package:sqflite/sqflite.dart';
// import 'package:'

// final testDBPath = '/core/timato.db';
EventRepository databaseHelper;

void main() {
  group("DB TEST", () {
    setUp(() async {
      WidgetsFlutterBinding.ensureInitialized();
      databaseHelper = EventRepository();
    });

    test("insert", () async {
      Event event = new Event(taskName: '打电话');
      int id = await databaseHelper.insertEvent(event);
      expect(id, greaterThan(0));
    });
  });
}

// void main() {
//   test('Event db', () async {
//     WidgetsFlutterBinding.ensureInitialized();
//     // const MethodChannel channel =
//     //     MethodChannel('plugins.flutter.io/path_provider');
//     // channel.setMockMethodCallHandler((MethodCall methodCall) async {
//     //   return ".";
//     // });
//     EventRepository databaseHelper = EventRepository();
//     Event tester = new Event(taskName: '写代码');
//     int id = await databaseHelper.insertEvent(tester);
//     expect(id, greaterThan(0));
//     // Future<int> count = databaseHelper.getCount();
//     // expect(count, 1);
//   });
// }
