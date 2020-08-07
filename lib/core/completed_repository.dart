import 'package:sqflite/sqflite.dart';
import 'package:date_format/date_format.dart' as ddlFormat;

import 'dart:async';
import 'db.dart';
import 'event.dart';

import 'dart:developer' as developer;

class CompletedEntity {
  static final String completedTable = 'completed_table';
  static final String colId = 'id';
  // static final String colKey = 'key';
  static final String colCompletedDate = 'completedDate';
  static final String colTaskName = 'task_name';
  static final String colTag = 'tag';
  static final String colPriority = 'priority';
  static final String colDDL = 'deadline';
  // static final String colDuration = 'duration';
  static final String colUnplanned = 'isUnplanned';
  // static final String colToday = 'isTodayList';
  // static final String colCompleted = 'isCompleted';
  static final String colWhichTask = 'whichTask';
  // static final String colTaskOrder = 'taskOrder';
  // static final String colTodayOrder = 'todayOrder';

  static void createCompletedTable(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $completedTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colCompletedDate TEXT,' +
            '$colTaskName TEXT, $colTag TEXT, $colPriority INTEGER, $colDDL TEXT,' +
            '$colUnplanned INTEGER,  $colWhichTask INTEGER)');
  }

  static upgradeDb(Database db, int oldVersion, int newVersion) async {
    if (newVersion == 10) {
      await db.execute('DROP TABLE $completedTable');
      await db.execute(
          'CREATE TABLE $completedTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colCompletedDate TEXT,' +
              '$colTaskName TEXT, $colTag TEXT, $colPriority INTEGER, $colDDL TEXT,' +
              '$colUnplanned INTEGER,  $colWhichTask INTEGER)');
    }
  }
// static void dropDb(Database db) async {
//   await db.execute('DROP TABLE $eventTable');
// }
}

Future<int> insertCompletedEvent(Event event) async {
  Database db = await DatabaseHelper.database;
  var result =
      await db.insert(CompletedEntity.completedTable, event.toMapCompleted());
  return result;
}

Future<List<Event>> getTodayCompletedList() async {
  DateTime today =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  String todayString = ddlFormat.formatDate(
      today, [ddlFormat.yyyy, '-', ddlFormat.mm, '-', ddlFormat.dd]);
  developer.log(todayString.length.toString());
  // developer.log();
  Database db = await DatabaseHelper.database;
  var todayCompletedMapList = await db.rawQuery(
      "SELECT * FROM ${CompletedEntity.completedTable} WHERE ${CompletedEntity.colCompletedDate} = '$todayString'"
      );
  int count = todayCompletedMapList
      .length; // Count the number of map entries in db table

  List<Event> todayCompletedList = List<Event>();
  // For loop to create a 'Event List' from a 'Map List'
  for (int i = 0; i < count; i++) {
    todayCompletedList
        .add(Event.fromMapObjectCompleted(todayCompletedMapList[i]));
  }
  developer.log('completed' + todayCompletedList.toString());
  return todayCompletedList;
}

Future<List<Event>> getYesterdayCompletedList() async {
  DateTime yesterday = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day - 1);
  String yesterdayString = ddlFormat.formatDate(
      yesterday, [ddlFormat.yyyy, '-', ddlFormat.mm, '-', ddlFormat.dd]);
  Database db = await DatabaseHelper.database;
  var yesterdayCompletedMapList = await db.rawQuery(
      "SELECT * FROM ${CompletedEntity.completedTable} WHERE ${CompletedEntity.colCompletedDate}= '$yesterdayString'");
  int count = yesterdayCompletedMapList
      .length; // Count the number of map entries in db table

  List<Event> yesterdayCompletedList = List<Event>();
  // For loop to create a 'Event List' from a 'Map List'
  for (int i = 0; i < count; i++) {
    yesterdayCompletedList
        .add(Event.fromMapObjectCompleted(yesterdayCompletedMapList[i]));
  }
  developer.log('yesterday completed' + yesterdayCompletedList.toString());
  return yesterdayCompletedList;
}

Future<List<Event>> getBeforeYesterdayCompletedList() async {
  DateTime today =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  String todayString = ddlFormat.formatDate(
      today, [ddlFormat.yyyy, '-', ddlFormat.mm, '-', ddlFormat.dd]);
  DateTime yesterday = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day - 1);
  String yesterdayString = ddlFormat.formatDate(
      yesterday, [ddlFormat.yyyy, '-', ddlFormat.mm, '-', ddlFormat.dd]);
  Database db = await DatabaseHelper.database;
  var beforeYesterdayCompletedMapList = await db.rawQuery(
      "SELECT * FROM ${CompletedEntity.completedTable} WHERE ${CompletedEntity.colCompletedDate} != '$todayString' AND ${CompletedEntity.colCompletedDate} != '$yesterdayString'");
  int count = beforeYesterdayCompletedMapList
      .length; // Count the number of map entries in db table

  List<Event> beforeYesterdayCompletedList = List<Event>();
  // For loop to create a 'Event List' from a 'Map List'
  for (int i = 0; i < count; i++) {
    beforeYesterdayCompletedList
        .add(Event.fromMapObjectCompleted(beforeYesterdayCompletedMapList[i]));
  }

  return beforeYesterdayCompletedList;
}

Future<int> deleteAllCompleted() async {
  var db = await DatabaseHelper.database;
  int result =
      await db.rawDelete('DELETE FROM ${CompletedEntity.completedTable}');
  return result;
}

Future<int> deleteToday() async {
  DateTime today =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  String todayString = ddlFormat.formatDate(
      today, [ddlFormat.yyyy, '-', ddlFormat.mm, '-', ddlFormat.dd]);
  var db = await DatabaseHelper.database;
  int result = await db.rawDelete(
      "DELETE FROM ${CompletedEntity.completedTable} WHERE ${CompletedEntity.colCompletedDate} = '$todayString'");
  return result;
}

Future<int> deleteYesterday() async {
  DateTime yesterday = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day - 1);
  String yesterdayString = ddlFormat.formatDate(
      yesterday, [ddlFormat.yyyy, '-', ddlFormat.mm, '-', ddlFormat.dd]);
  var db = await DatabaseHelper.database;
  int result = await db.rawDelete(
      "DELETE FROM ${CompletedEntity.completedTable} WHERE ${CompletedEntity.colCompletedDate} = '$yesterdayString'");
  return result;
}

Future<int> deleteBeforeYesterday() async {
  DateTime today =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  String todayString = ddlFormat.formatDate(
      today, [ddlFormat.yyyy, '-', ddlFormat.mm, '-', ddlFormat.dd]);
  DateTime yesterday = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day - 1);
  String yesterdayString = ddlFormat.formatDate(
      yesterday, [ddlFormat.yyyy, '-', ddlFormat.mm, '-', ddlFormat.dd]);
  var db = await DatabaseHelper.database;
  int result = await db.rawDelete(
      "DELETE FROM ${CompletedEntity.completedTable} WHERE ${CompletedEntity.colCompletedDate} != '$todayString' AND ${CompletedEntity.colCompletedDate} != '$yesterdayString'");
  return result;
}
