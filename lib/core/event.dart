///Splits priotity into three levels
enum Priority{
    HIGH, MIDDLE, LOW, NONE
  }


final Map<Priority, int> _priorityInt = {
    Priority.HIGH: 3,
    Priority.MIDDLE: 2,
    Priority.LOW: 1,
    Priority.NONE: 0
  };

final Map<int, String> _priorityString = {
  3: 'High',
  2: 'Middle',
  1: 'Low',
  0: 'None'
};

final Map<String, Priority> _priorityEnum = {
    'High' : Priority.HIGH,
    'Middle' : Priority.MIDDLE,
    'Low' : Priority.LOW,
    'None' : Priority.NONE
  };

///A event that user adds onto the todo list
class Event{
  // final Map<String, Priority> _priorityEnum = {
  //   'High' : Priority.HIGH,
  //   'Middle' : Priority.MIDDLE,
  //   'Low' : Priority.LOW,
  //   'None' : Priority.NONE
  // };
  ///Maps each [Event.eventPriority] to a number
  // static final Map<Priority, int> _priorityLevel = {
  //   Priority.HIGH: 3,
  //   Priority.MIDDLE: 2,
  //   Priority.LOW: 1,
  //   Priority.NONE: 0,
  // };

  ///Maps each [Event.eventPriority] to a String
  // static final Map<Priority, String> _priorityString = {
  //   Priority.HIGH: 'High',
  //   Priority.MIDDLE: 'Middle',
  //   Priority.LOW: 'Low',
  //   Priority.NONE: 'None',
  // };

  ///Each event has its [id] to be indentified
  int id;
  ///Event's name
  String taskName;
  ///The date that the [Event] is due
  DateTime ddl;
  ///Each clock is set to be 1500 seconds
  int clockLen = 1500;
  ///The time duration reach [Event] is expected
  //int duration = 0;
  ///A category that the [Event] belongs to
  String tag;
  ///Indicator for whether the [Event] repeats everyday
  bool repeat;
  ///The [Event]'s priority level
  Priority eventPriority = Priority.NONE;
  ///Number of clocks needed
  int numClock;
  
  // String get eventPriorityString => _priorityString[this.eventPriority];
  // void set eventPriorityString(String priority)=> this.eventPriorityString=priority;

  // Priority get eventPriority => _priorityLevel[this.eventPriority];
  //void set eventPriority(String priority)=> this.eventPriority=priority;

  //Priority get eventPriorityEnum => _priorityLevel[this.priority];

  ///List of all the [Subevent] this [Event] has
  ///
  ///This list includes sample [Subevent]
  List subeventsList = <Subevent> [
    new Subevent(subeventName: 'sub1',subeventPriority: Priority.MIDDLE)
  ];
  ///bool isExpanded = false;
  
  Event({this.id,this.taskName,this.ddl,this.eventPriority, this.tag, this.numClock});

  ///Number of clocks each event needs
  //int get numClock => (duration/clockLen).ceil();

  ///Returns the event that has higher priority
  Event higherPriority(Event other) {
    if (_priorityInt[this.eventPriority] >= _priorityInt[other.eventPriority]) {
      return this;
    } else {
      return other;
    }
  }

  ///Adds new [Subevent] to the [subeventsList]
  void addSub(String subName) {
    Subevent sub = new Subevent(subeventName:subName);
    subeventsList.add(sub);
  }
}

class Subevent {
  ///Maps each [Subevent._priorityLevel] to a number
  static final Map<Priority, int> _priorityLevel = {
    Priority.HIGH: 3,
    Priority.MIDDLE: 2,
    Priority.LOW: 1,
    Priority.NONE: 0,
  };

  int id;
  String subeventName;
  DateTime subeventDdl;
  int subeventLen = 0;
  ///The [Subevent]'s priority level
  Priority subeventPriority = Priority.NONE;

  Subevent({this.id, this.subeventName, this.subeventDdl, this.subeventPriority});
}
