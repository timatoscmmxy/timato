import 'package:sqflite/sqflite.dart';

import 'dart:async';
import 'db.dart';
import 'event.dart';

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
        'CREATE TABLE $completedTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colCompletedDate TEXT' +
            '$colTaskName TEXT, $colTag TEXT, $colPriority INTEGER, $colDDL TEXT,'+
            '$colUnplanned INTEGER,  $colWhichTask INTEGER)');
  }

  static upgradeDb(Database db, int oldVersion, int newVersion) async {
    if (newVersion == 1) {
      await db.execute('DROP TABLE $completedTable');
      await db.execute(
          'CREATE TABLE $completedTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colCompletedDate TEXT' +
            '$colTaskName TEXT, $colTag TEXT, $colPriority INTEGER, $colDDL TEXT,'+
            '$colUnplanned INTEGER,  $colWhichTask INTEGER)');
    }
  }

// static void dropDb(Database db) async {
//   await db.execute('DROP TABLE $eventTable');
// }
}

Future<int> insertCompletedEvent(Event event) async {
  Database db = await DatabaseHelper.database;
  var result = await db.insert(CompletedEntity.completedTable, event.toMap());
  return result;
}

Future<List<Event>> getTodayCompletedList() async {
  String today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).toString();
  Database db = await DatabaseHelper.database;
  var todayCompletedMapList = await db.rawQuery(
      'SELECT * FROM ${CompletedEntity.completedTable} WHERE ${CompletedEntity.colCompletedDate}= $today)');
  int count =
      todayCompletedMapList.length; // Count the number of map entries in db table

  List<Event> todayCompletedList = List<Event>();
  // For loop to create a 'Event List' from a 'Map List'
  for (int i = 0; i < count; i++) {
    todayCompletedList.add(Event.fromMapObject(todayCompletedMapList[i]));
  }

  return todayCompletedList;
}

Future<List<Event>> getYesterdayCompletedList() async {
  String yesterday = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day-1).toString();
  Database db = await DatabaseHelper.database;
  var yesterdayCompletedMapList = await db.rawQuery(
      'SELECT * FROM ${CompletedEntity.completedTable} WHERE ${CompletedEntity.colCompletedDate}= $yesterday)');
  int count =
      yesterdayCompletedMapList.length; // Count the number of map entries in db table

  List<Event> yesterdayCompletedList = List<Event>();
  // For loop to create a 'Event List' from a 'Map List'
  for (int i = 0; i < count; i++) {
    yesterdayCompletedList.add(Event.fromMapObject(yesterdayCompletedMapList[i]));
  }

  return yesterdayCompletedList;
}

Future<List<Event>> getBeforeYesterdayCompletedList() async {
  String today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).toString();
  String yesterday = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day-1).toString();
  Database db = await DatabaseHelper.database;
  var beforeYesterdayCompletedMapList = await db.rawQuery(
      'SELECT * FROM ${CompletedEntity.completedTable} WHERE ${CompletedEntity.colCompletedDate} != $today AND ${CompletedEntity.colCompletedDate} != $yesterday)');
  int count =
      beforeYesterdayCompletedMapList.length; // Count the number of map entries in db table

  List<Event> beforeYesterdayCompletedList = List<Event>();
  // For loop to create a 'Event List' from a 'Map List'
  for (int i = 0; i < count; i++) {
    beforeYesterdayCompletedList.add(Event.fromMapObject(beforeYesterdayCompletedMapList[i]));
  }

  return beforeYesterdayCompletedList;
}

Future<int> deleteAllCompleted() async {
  var db = await DatabaseHelper.database;
  int result = await db.rawDelete('DELETE FROM ${CompletedEntity.completedTable}');
  return result;
}

Future<int> deleteToday() async {
  String today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).toString();
  var db = await DatabaseHelper.database;
  int result = await db.rawDelete('DELETE FROM ${CompletedEntity.completedTable} WHERE ${CompletedEntity.colCompletedDate} = $today');
  return result;
}

Future<int> deleteYesterday() async {
  String yesterday = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day-1).toString();
  var db = await DatabaseHelper.database;
  int result = await db.rawDelete('DELETE FROM ${CompletedEntity.completedTable} WHERE ${CompletedEntity.colCompletedDate} = $yesterday');
  return result;
}

Future<int> deleteBeforeYesterday() async {
  String today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).toString();
  String yesterday = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day-1).toString();
  var db = await DatabaseHelper.database;
  int result = await db.rawDelete('DELETE FROM ${CompletedEntity.completedTable} WHERE ${CompletedEntity.colCompletedDate} != $today AND ${CompletedEntity.colCompletedDate} != $yesterday');
  return result;
}