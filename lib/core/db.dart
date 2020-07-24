import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:timato/core/event.dart';
import 'dart:developer' as developer;

import 'package:timato/core/tag.dart';

abstract class DatabaseHelper {
  // static DatabaseHelper _databaseHelper; // Singleton DatabaseHelper
  static Database _database; // Singleton Database

  // DatabaseHelper._createInstance(); // Named constructor to create instance of DatabaseHelper

  // factory DatabaseHelper() {
  //   if (_databaseHelper == null) {
  //     _databaseHelper = DatabaseHelper
  //         ._createInstance(); // This is executed only once, singleton object
  //   }
  //   return _databaseHelper;
  // }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    // Get the directory path for both Android and iOS to store database.
    // Directory directory = await getApplicationDocumentsDirectory();
    // String path = directory.path + '/core/timato.db';
    String path = join(await getDatabasesPath(), 'timato.db');

    developer.log(path);
    // Open/create the database at a given path
    var database = await openDatabase(path,
        version: 5, onCreate: _createDb, onUpgrade: _upgradeDb);
    //_dropDb(database);
    return database;
  }

  void _createDb(Database db, int newVersion) async {
    EventEntity.createEventTable(db, newVersion);
    TagEntity.createDb(db, newVersion);
    // 	await db.execute('CREATE TABLE $eventTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colKey TEXT, '
    // + '$colTaskName TEXT, $colTag TEXT, $colPriority INTEGER, $colDDL TEXT, $colDuration INTEGER), $colUnplanned INTEGER, $colToday INTEGER');
  }

  void _upgradeDb(Database db, int oldVersion, int newVersion) async {
    EventEntity.upgradeDb(db, oldVersion, newVersion);
    TagEntity.upgradeDb(db, oldVersion, newVersion);
  }

  // void _dropDb(Database db) async {
  //   EventEntity.dropDb(db);
  //   // await db.execute('DROP TABLE $eventTable');
  // }
}
