import 'package:flutter/widgets.dart';

import 'package:meta/meta.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:timato/core/repeat_properties.dart';
import 'package:timato/ui/basics.dart';

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
  String tag ;

  ///The [Event]'s priority level
  Priority eventPriority = Priority.NONE;

  // get eventPriorityInt {
  //   return ConstantHelper.priorityLevel(eventPriority);
  // }

  ///Indicates whether the event is done
  bool isDone = false;

  ///Repeat Properties
  RepeatProeprties repeatProperties;

  int usedTimerNum = 0;

  ///The key used to identify individual events
  Key key;

  AbstractEvent({
    @required String taskName,
    Key key,
    DateTime ddl,
    int duration,
    String tag,
    Priority eventPriority = Priority.NONE,
  }) {
    this.taskName = taskName;
    this.ddl = null;
    this.duration = duration;
    this.tag = tag;
    this.eventPriority = eventPriority;
    this.key = UniqueKey();
  }

  ///List of all the [Subevent] this [Event] has
  ///
  ///This list includes sample [Subevent]

  ///Number of clocks each event needs
  get clockNum async {
    if(duration == null){
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

///A event that user adds onto the list
class Event extends AbstractEvent {
  int id;

  // final List subeventsList = <Subevent> [];
  ///List of all the [Subevent] this [Event] has
  ///
  ///This list includes sample [Subevent]
  final List subeventsList = <Subevent>[
    new Subevent(taskName: 'sub1', eventPriority: Priority.MIDDLE)
  ];

  Event({
    @required String taskName,
    DateTime ddl,
    int duration,
    String tag,
    Priority eventPriority = Priority.NONE,
    key,
  }) : super(
            taskName: taskName,
            ddl: ddl,
            duration: duration,
            tag: tag,
            eventPriority: eventPriority,
            );

  Event.fromMapObject(Map<String, dynamic> map) {
    this.id = map["id"];
    this.key = Key(map["key"]);
    this.taskName = map["task_name"];
    this.ddl = DateTime.parse(map["deadline"]);
    this.tag = map["tag"];
    this.duration = map["duration"];
    this.eventPriority = ConstantHelper.priorityEnum[ConstantHelper.priorityIntString[map["priority"]]];
  }

  ///Database implementation
  ///
  ///Converts an [Event] into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'key': key.toString(),
      'task_name': taskName,
      'deadline': ddl.toString(),
      'duration': duration,
      'tag': tag,
      'priority': ConstantHelper.priorityLevel[eventPriority],
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
