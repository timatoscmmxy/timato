import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:meta/meta.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:path/path.dart';

import 'package:sqflite/sqflite.dart';

import 'package:timato/ui/basics.dart';
import 'package:timato/core/db.dart';

enum RepeatUnit { day, week, month, year }

enum WeekNum { First, Second, Third, Fourth, Last }

class RepeatProperties {
  /// The unit of repeating time
  RepeatUnit unit;

  /// Repeat Every [unitNum] [unit]
  int unitNum;

  /// The day starts repeating
  DateTime start;

  /// Repeat every weekday if [unit] is [RepeatUnit.week]
  /// Or repeat on every [weekNum] [weekday] if [unit] is [RepeatUnit.month]
  /// Use [DateTime.monday] ... for weekdays
  List<int> weekdays;
  WeekNum weekNum;

  /// Repeat every monthDay if [unit] is [RepeatUnit.month]
  /// 0 is the last day of the month, otherwise, 1 <= [monthDay] <= 31
  int monthDay;

  RepeatProperties(
      {@required this.unit,
      @required this.unitNum,
      @required this.start,
      List<int> weekdays,
      WeekNum weekNum,
      int monthDay}) {
    if (unit == RepeatUnit.week) {
      if (weekdays == null) {
        throw ArgumentError('week Day cannot be Null');
      } else {
        this.weekdays = weekdays;
      }
    } else if (unit == RepeatUnit.month) {
      if (monthDay != null) {
        this.monthDay = monthDay;
      } else if (weekdays != null && weekNum != null) {
        this.weekdays = weekdays;
        this.weekNum = weekNum;
      } else {
        throw ArgumentError('need monthDay or weekDay and weekNum');
      }
    }
  }

  /// Determine whether today is the repeated date
  bool isToday(DateTime today) {
    if (start.isAfter(today)) return false;

    Duration diff = start.difference(today);
    switch (this.unit) {
      case RepeatUnit.day:
        return diff.inDays % unitNum == 0;
        break;
      case RepeatUnit.week:
        return weekdays.contains(today.weekday) &&
            (this._diffInWeek(today, diff) % unitNum == 0);
        break;
      case RepeatUnit.month:
        if (this._diffInMonth(today) % unitNum == 0) {
          return (monthDay == today.day)
              // monthDay == 0 means last day in the month
              ||
              (monthDay == 0 &&
                  today.day ==
                      DateTime(today.year, today.month + 1, 1)
                          .add(Duration(days: -1))
                          .day)
              // nth Weekday situation
              ||
              (today.weekday == weekdays[0] && _nthWeekdayMatches(today));
        } else {
          return false;
        }
        break;
      case RepeatUnit.year:
        return today.isAtSameMomentAs(start) &&
            ((today.year - start.year) % unitNum == 0);
        break;
      default:
        return false;
    }
  }

  /// turn [diff] in days into difference in weeks between [today] and [start]
  int _diffInWeek(DateTime today, Duration diff) {
    int num = diff.inDays ~/ DateTime.daysPerWeek;
    if (today.weekday < this.start.weekday) ++num;
    return num;
  }

  /// return difference in months between [today] and [start]
  int _diffInMonth(DateTime today) {
    return (today.year - start.year) * 12 + (today.month - start.month);
  }

  /// Check whether [today] is the [weekNum]th weekday
  bool _nthWeekdayMatches(DateTime today) {
    int day = today.day;
    int weekday = today.weekday;
    int firstWeekdayInMonth = DateTime(today.year, today.month, 1).weekday;
    DateTime lastDayInMonth =
        DateTime(today.year, today.month + 1, 1).add(Duration(days: -1));
    int lastWeekdayInMonth = lastDayInMonth.weekday;
    int firstOccurrence = weekday >= firstWeekdayInMonth
        ? (weekday - firstWeekdayInMonth) + 1
        : (8 - firstWeekdayInMonth) + weekday;
    int lastOccurrence = weekday <= lastWeekdayInMonth
        ? lastDayInMonth.day - (lastWeekdayInMonth - weekday)
        : lastDayInMonth.day - 7 + (weekday - lastWeekdayInMonth);
    switch (this.weekNum) {
      case WeekNum.First:
        return day == firstOccurrence;
        break;
      case WeekNum.Second:
        return day == firstOccurrence + 7;
        break;
      case WeekNum.Third:
        return day == firstOccurrence + 14;
        break;
      case WeekNum.Fourth:
        return day == firstOccurrence + 21;
        break;
      case WeekNum.Last:
        return day == lastOccurrence;
        break;
      default:
        return false;
    }
  }
}

abstract class AbstractEvent implements Comparable {
  ///Event's name
  String taskName;

  ///The date that the [Event] is due
  DateTime ddl;

  ///The time duration reach [Event] is expected
  int duration;

  ///Number of clocks needed
  int numClock;

  ///A category that the [Event] belongs to
  String tag = 'daily task';

  ///The date that the event is completed
  DateTime completedDate;

  ///The [Event]'s priority level
  Priority eventPriority = Priority.NONE;

  // get eventPriorityInt {
  //   return ConstantHelper.priorityLevel(eventPriority);
  // }

  ///Indicates whether the event is done
  int isCompleted = 0;

  ///Indicates whether this [Event] is on today's list
  int isTodayList = 0;

  ///Indicates whether this [Event] is unplanned
  int isUnplanned = 0;

  ///Repeat Properties
  RepeatProperties repeatProperties;

  ///The key used to identify individual events
  Key key;

  AbstractEvent(
      {@required String taskName,
      Key key,
      DateTime ddl,
      int duration,
      String tag,
      Priority eventPriority = Priority.NONE,
      RepeatProperties repeatProperties,
      DateTime completedDate,
      int isTodayList,
      int isUnplanned}) {
    this.taskName = taskName;
    this.ddl = DateTime.now();
    this.duration = duration;
    this.tag = tag;
    this.eventPriority = eventPriority;
    this.repeatProperties = repeatProperties;
    this.key = UniqueKey();
    this.completedDate = completedDate;
    this.isTodayList = isTodayList;
    this.isUnplanned = isUnplanned;
  }

  ///List of all the [Subevent] this [Event] has
  ///
  ///This list includes sample [Subevent]

  ///Number of clocks each event needs
  get clockNum async {
    if (duration == null) {
      return null;
    }
    SharedPreferences pref = await SharedPreferences.getInstance();
    int clockLen = pref.getInt('timerLength') ?? 25 * 60;
    return (duration * 60 / clockLen).ceil();
  }

  @override
  int compareTo(other) {
    if (other is AbstractEvent) {
      if (ConstantHelper.priorityLevel[this.eventPriority] >
          ConstantHelper.priorityLevel[other.eventPriority]) {
        return 1;
      } else if (ConstantHelper.priorityLevel[this.eventPriority] ==
          ConstantHelper.priorityLevel[other.eventPriority]) {
        return 0;
      } else {
        return -1;
      }
    } else {
      throw ArgumentError(
          "AbstractEvent object can only be compared with another AbstractEvent object");
    }
  }

  // ///Number of clocks needed
  // int numClock;

  // int duration = 0;

  ///Returns the event that has higher priority
  AbstractEvent higherPriority(AbstractEvent other) {
    if (ConstantHelper.priorityLevel[this.eventPriority] >=
        ConstantHelper.priorityLevel[other.eventPriority]) {
      return this;
    } else {
      return other;
    }
  }
}

///A event that user adds onto the todo list
class Event extends AbstractEvent {
  int id;

  // final List subeventsList = <Subevent> [];
  ///List of all the [Subevent] this [Event] has
  ///
  ///This list includes sample [Subevent]
  final List subeventsList = <Subevent>[
    new Subevent(taskName: 'sub1', eventPriority: Priority.MIDDLE)
  ];

  Event(
      {@required String taskName,
      DateTime ddl,
      int duration,
      String tag,
      Priority eventPriority = Priority.NONE,
      RepeatProperties repeatProperties,
      DateTime completedDate,
      key,
      int isTodayList,
      int isUnplanned})
      : super(
          taskName: taskName,
          ddl: ddl,
          duration: duration,
          tag: tag,
          eventPriority: eventPriority,
          repeatProperties: repeatProperties,
          completedDate: completedDate,
          isTodayList: isTodayList,
          isUnplanned: isUnplanned,
        );

  Event.fromMapObject(Map<String, dynamic> map) {
    this.id = map["id"];
    this.key = Key(map["key"]);
    this.taskName = map["task_name"];
    this.ddl = DateTime.parse(map["deadline"]);
    this.tag = map["tag"]??"";
    this.duration = map["duration"];
    this.eventPriority = ConstantHelper
        .priorityEnum[ConstantHelper.priorityIntString[map["priority"]]];
    this.isTodayList = map["isTodayList"];
    this.isCompleted = map["isCompleted"];
    this.isUnplanned = map["isUnplanned"];
  }

  ///Database implementation
  ///
  ///Converts an [Event] into a Map
  Map<String, dynamic> toMap() {
    return {
      //TODO: add completedDate into the table
      'id': id,
      'key': key.toString(),
      'task_name': taskName,
      'deadline': ddl.toString(),
      'duration': duration,
      'tag': tag,
      'priority': ConstantHelper.priorityLevel[eventPriority],
      'isTodayList':isTodayList,
      'isCompleted': isCompleted,
      'isUnplanned': isUnplanned
      // 'subeventsList': subeventsList
    };
  }

  // ///Defines a function that inserts events into the database
  // Future<void> insertEvent(Event task) async {
  //   final Database db = await database;
  // }

  ///Adds new [Subevent] to the [subeventsList]
  void addSub(String subName) {
    Subevent sub = new Subevent(taskName: subName);
    subeventsList.add(sub);
  }
}

class Subevent extends AbstractEvent {
  Subevent({
    @required String taskName,
    Key key,
    DateTime ddl,
    int duration,
    String tag,
    Priority eventPriority = Priority.NONE,
  }) : super(
            taskName: taskName,
            key: key,
            ddl: ddl,
            duration: duration,
            tag: tag,
            eventPriority: eventPriority);
}

class EventEntity {
  static final String eventTable = 'event_table';
  static final String colId = 'id';
  static final String colKey = 'key';
  static final String colTaskName = 'task_name';
  static final String colTag = 'tag';
  static final String colPriority = 'priority';
  static final String colDDL = 'deadline';
  static final String colDuration = 'duration';
  static final String colUnplanned = 'isUnplanned';
  static final String colToday = 'isTodayList';
  static final String colCompleted = 'isCompleted';

  static void createDb(Database db, int newVersion) async {
    await db.execute(
          'CREATE TABLE $eventTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colKey TEXT, ' +
              '$colTaskName TEXT, $colTag TEXT, $colPriority INTEGER, $colDDL TEXT, $colDuration INTEGER, $colUnplanned INTEGER, $colToday INTEGER, $colCompleted INTEGER)');
  }

  static upgradeDb(Database db, int oldVersion, int newVersion) async {
    if (newVersion == 5) {
      await db.execute('DROP TABLE $eventTable');
      await db.execute(
          'CREATE TABLE $eventTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colKey TEXT, ' +
              '$colTaskName TEXT, $colTag TEXT, $colPriority INTEGER, $colDDL TEXT, $colDuration INTEGER, $colUnplanned INTEGER, $colToday INTEGER, $colCompleted INTEGER)');
    }
  }

  // static void dropDb(Database db) async {
  //   await db.execute('DROP TABLE $eventTable');
  // }
}
