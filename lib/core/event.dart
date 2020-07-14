import 'package:meta/meta.dart';

import 'package:shared_preferences/shared_preferences.dart';

enum RepeatUnit{
  day, week, month, year
}

enum WeekDay{
  Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday
}

enum WeekNum{
  First, Second, Third, Fourth, Last
}

class RepeatProperties{
  /// The unit of repeating time
  RepeatUnit unit;
  /// Repeat Every [unitNum] [unit]
  int unitNum;
  /// The day starts repeating
  DateTime start;

  /// Repeat every weekday if [unit] is [RepeatUnit.week]
  /// Or repeat on every [weekNum] [weekday] if [unit] is [RepeatUnit.month]
  WeekDay weekday;
  WeekNum weekNum;

  /// Repeat every monthDay if [unit] is [RepeatUnit.month]
  /// 0 is the last day of the month, otherwise, 1 <= [monthDay] <= 31
  int monthDay;


  RepeatProperties(
      { @required this.unit,
        @required this.unitNum,
        @required this.start,
        WeekDay weekDay,
        WeekNum weekNum,
        int monthDay}){
    if (unit == RepeatUnit.week){
      if (weekDay == null){
        throw ArgumentError('week Day cannot be Null');
      } else{
        this.weekday = weekDay;
      }
    } else if (unit == RepeatUnit.month){
      if (monthDay != null){
        this.monthDay = monthDay;
      } else if (weekDay != null && weekNum != null){
        this.weekday = weekDay;
        this.weekNum = weekNum;
      } else{
        throw ArgumentError('need monthDay or weekDay and weekNum');
      }
    }
  }
}

///Splits priotity into three levels
enum Priority{
  HIGH, MIDDLE, LOW, NONE
}

abstract class AbstractEvent implements Comparable{
  ///Maps each [Event._priorityLevel] to a number
  static final Map<Priority, int> priorityLevel = {
    Priority.HIGH: 3,
    Priority.MIDDLE: 2,
    Priority.LOW: 1,
    Priority.NONE: 0,
  };

  ///Event's name
  String taskName;
  ///The date that the [Event] is due
  DateTime ddl;
  ///The time duration reach [Event] is expected
  int duration = 0;
  ///A category that the [Event] belongs to
  String tag;
  ///The [Event]'s priority level
  Priority eventPriority;
  ///Indicates whether the event is done
  bool isDone = false;
  ///Repeat Properties
  RepeatProperties repeatProperties;
  ///List of all the [Subevent] this [Event] has
  ///
  ///This list includes sample [Subevent]

  ///Number of clocks each event needs
  get clockNum async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    int clockLen = pref.getInt('timerLength')??25*60;
    return (duration*60/clockLen).ceil();
  }

  @override
  int compareTo(other){
    if (other is AbstractEvent){
      if (AbstractEvent.priorityLevel[this.eventPriority] > AbstractEvent.priorityLevel[other.eventPriority]) {
        return 1;
      } else if (AbstractEvent.priorityLevel[this.eventPriority] == AbstractEvent.priorityLevel[other.eventPriority]) {
        return 0;
      } else{
        return -1;
      }
    } else{
      throw ArgumentError("AbstractEvent object can only be compared with another AbstractEvent object");
    }
  }
}

///A event that user adds onto the todo list
class Event extends AbstractEvent{
  final List subeventsList = <Subevent> [];

  Event(
      { @required String taskName,
        DateTime ddl,
        int duration,
        String tag,
        Priority eventPriority = Priority.NONE,
        RepeatProperties repeatProperties}){
    this.taskName = taskName;
    this.ddl = ddl;
    this.duration = duration;
    this.tag = tag;
    this.eventPriority = eventPriority;
    this.repeatProperties = repeatProperties;
  }

  ///Adds new [Subevent] to the [subeventsList]
  void addSub(String subName) {
    Subevent sub = new Subevent(taskName: subName);
    subeventsList.add(sub);
  }
}

class Subevent extends AbstractEvent {
  Subevent(
      { @required String taskName,
        DateTime ddl,
        int duration,
        String tag,
        Priority eventPriority = Priority.NONE,
      }){
    this.taskName = taskName;
    this.ddl = ddl;
    this.duration = duration;
    this.tag = tag;
    this.eventPriority = eventPriority;
  }
}
