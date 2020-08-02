import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:timato/core/event.dart';
import 'dart:developer' as developer;

import 'package:timato/core/tag_repository.dart';

class DatabaseHelper {
  static Database _database; // Singleton Database

  static Future<Database> get database async {
    if (_database == null) {
      _database = await _initializeDatabase();
    }
    return _database;
  }

  static Future<Database> _initializeDatabase() async {
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

  static void _createDb(Database db, int newVersion) async {
    EventEntity.createDb(db, newVersion);
    TagEntity.createDb(db, newVersion);
  }

  static void _upgradeDb(Database db, int oldVersion, int newVersion) async {
    EventEntity.upgradeDb(db, oldVersion, newVersion);
    TagEntity.upgradeDb(db, oldVersion, newVersion);
  }
}
