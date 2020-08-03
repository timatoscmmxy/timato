import 'package:sqflite/sqflite.dart';

import 'dart:async';
import 'db.dart';
import 'event.dart';


class EventRepository extends DatabaseHelper {
  static EventRepository _databaseHelper; // Singleton DatabaseHelper
  EventRepository._createInstance(); // Named constructor to create instance of DatabaseHelper

  factory EventRepository() {
    if (_databaseHelper == null) {
      _databaseHelper = EventRepository
          ._createInstance(); // This is executed only once, singleton object
    }
    return _databaseHelper;
  }

  // Fetch Operation: Get all event objects from database
  Future<List<Map<String, dynamic>>> getEventMapList() async {
    Database db = await this.database;

//		var result = await db.rawQuery('SELECT * FROM $eventTable order by $colPriority ASC');
    var result = await db.query(EventEntity.eventTable,
        orderBy: '${EventEntity.colPriority} DESC');
    return result;
  }

  // Insert Operation: Insert a Event object to database
  Future<int> insertEvent(Event event) async {
    Database db = await this.database;
    var result = await db.insert(EventEntity.eventTable, event.toMap());
    return result;
  }

  // Update Operation: Update a Event object and save it to database
  Future<int> updateEvent(Event event) async {
    var db = await this.database;
    var result = await db.update(EventEntity.eventTable, event.toMap(),
        where: '${EventEntity.colId} = ?', whereArgs: [event.id]);
    return result;
  }

  // Delete Operation: Delete an Event object from database
  Future<int> deleteEvent(int id) async {
    var db = await this.database;
    int result = await db.rawDelete(
        'DELETE FROM ${EventEntity.eventTable} WHERE ${EventEntity.colId} = $id');
    return result;
  }

  //Deletes all the data on eventTable
  Future<int> deleteAll(int id) async {
    var db = await this.database;
    int result = await db.rawDelete(
        'DELETE FROM ${EventEntity.eventTable}');
    return result;
  }

  // Get number of Event objects in database
  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from ${EventEntity.eventTable}');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  // Get the 'Map List' [ List<Map> ] and convert it to 'Event List' [ List<Event> ]
  Future<List<Event>> getEventList() async {
    var eventMapList = await getEventMapList(); // Get 'Map List' from database
    int count =
        eventMapList.length; // Count the number of map entries in db table

    List<Event> eventList = List<Event>();
    // For loop to create a 'Event List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      eventList.add(Event.fromMapObject(eventMapList[i]));
    }

    return eventList;
  }

  Future<List<Event>> getTodayEventList() async {
    Database db = await this.database;
    var todayEventMapList = await db.rawQuery('SELECT * FROM ${EventEntity.eventTable} WHERE ${EventEntity.colToday}=?', [1]);
    int count =
        todayEventMapList.length; // Count the number of map entries in db table

    List<Event> todayEventList = List<Event>();
    // For loop to create a 'Event List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      todayEventList.add(Event.fromMapObject(todayEventMapList[i]));
    }

    return todayEventList;
  }

  Future<List<Event>> getUnpannedThing() async {
    Database db = await this.database;
    var unplannedThingMapList = await db.rawQuery('SELECT * FROM ${EventEntity.eventTable} WHERE ${EventEntity.colUnplanned}=?', [1]);
    int count =
        unplannedThingMapList.length; // Count the number of map entries in db table

    List<Event> unplannedThingList = List<Event>();
    // For loop to create a 'Event List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      unplannedThingList.add(Event.fromMapObject(unplannedThingMapList[i]));
    }

    return unplannedThingList;
  }
}