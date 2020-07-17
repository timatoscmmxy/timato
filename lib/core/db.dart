import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:timato/core/event.dart';
import 'dart:developer' as developer;

class DatabaseHelper {

	static DatabaseHelper _databaseHelper;    // Singleton DatabaseHelper
	static Database _database;                // Singleton Database

	String eventTable = 'event_table';
  String colId = 'id';
	String colKey = 'key';
	String colTaskName = 'task_name';
	String colTag = 'tag';
	String colPriority = 'priority';
	String colDDL = 'deadline';
  String colDuration = 'duration';

	DatabaseHelper._createInstance(); // Named constructor to create instance of DatabaseHelper

	factory DatabaseHelper() {

		if (_databaseHelper == null) {
			_databaseHelper = DatabaseHelper._createInstance(); // This is executed only once, singleton object
		}
		return _databaseHelper;
	}

	Future<Database> get database async {

		if (_database == null) {
			_database = await initializeDatabase();
		}
		return _database;
	}

	Future<Database> initializeDatabase() async {
		// Get the directory path for both Android and iOS to store database.
		Directory directory = await getApplicationDocumentsDirectory();
		String path = directory.path + '/core/timato.db';

    developer.log(path);
		// Open/create the database at a given path
		var database = await openDatabase(path, version: 2, onCreate: _createDb);
    //_dropDb(database);
		return database;
	}

	void _createDb(Database db, int newVersion) async {

		await db.execute('CREATE TABLE $eventTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colKey TEXT, '
  + '$colTaskName TEXT, $colTag TEXT, $colPriority INTEGER, $colDDL TEXT, $colDuration INTEGER)');
	}

  void _dropDb(Database db) async {

		await db.execute('DROP TABLE $eventTable');
	}

	// Fetch Operation: Get all event objects from database
	Future<List<Map<String, dynamic>>> getEventMapList() async {
		Database db = await this.database;

//		var result = await db.rawQuery('SELECT * FROM $eventTable order by $colPriority ASC');
		var result = await db.query(eventTable, orderBy: '$colPriority DESC');
		return result;
	}

	// Insert Operation: Insert a Event object to database
	Future<int> insertEvent(Event event) async {
		Database db = await this.database;
		var result = await db.insert(eventTable, event.toMap());
		return result;
	}

	// Update Operation: Update a Event object and save it to database
	Future<int> updateEvent(Event event) async {
		var db = await this.database;
		var result = await db.update(eventTable, event.toMap(), where: '$colId = ?', whereArgs: [event.id]);
		return result;
	}

	// Delete Operation: Delete an Event object from database
	Future<int> deleteEvent(int id) async {
		var db = await this.database;
		int result = await db.rawDelete('DELETE FROM $eventTable WHERE $colId = $id');
		return result;
	}

	// Get number of Event objects in database
	Future<int> getCount() async {
		Database db = await this.database;
		List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT (*) from $eventTable');
		int result = Sqflite.firstIntValue(x);
		return result;
	}

	// Get the 'Map List' [ List<Map> ] and convert it to 'Event List' [ List<Event> ]
	Future<List<Event>> getEventList() async {

		var eventMapList = await getEventMapList(); // Get 'Map List' from database
		int count = eventMapList.length;         // Count the number of map entries in db table

		List<Event> eventList = List<Event>();
		// For loop to create a 'Event List' from a 'Map List'
		for (int i = 0; i < count; i++) {
			eventList.add(Event.fromMapObject(eventMapList[i]));
		}

		return eventList;
	}

}
