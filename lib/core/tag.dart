import 'package:sqflite/sqflite.dart';

class TagEntity {
  static final String tagTable = 'tag_table';
  static final String colId = 'id';
  static final String colName = 'name';

  static void createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $tagTable($colId INTEGER PRIMARY KEY AUTOINCREMENT,' +
            '$colName TEXT)');
    await db.execute(
        'INSERT INTO $tagTable ($colId, $colName) VALUES(0, "English")');
    await db.execute(
        'INSERT INTO $tagTable ($colId, $colName) VALUES(1, "Chinese")');
  }

  static upgradeDb(Database db, int oldVersion, int newVersion) async {
    if (newVersion == 3) {
      await db.execute(
          'CREATE TABLE $tagTable($colId INTEGER PRIMARY KEY AUTOINCREMENT,' +
              '$colName TEXT)');
      await db.execute(
          'INSERT INTO $tagTable ($colId, $colName) VALUES(0, "English")');
      await db.execute(
          'INSERT INTO $tagTable ($colId, $colName) VALUES(1, "Chinese")');
    }
  }

  // static void dropDb(Database db) async {
  //   await db.execute('DROP TABLE $eventTable');
  // }
}
