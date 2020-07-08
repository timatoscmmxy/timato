///Splits priotity into three levels
enum Priority{
    HIGH, MIDDLE, LOW, NONE
  }

///A event that user adds onto the todo list
class Event{
  ///Maps each [Event._priorityLevel] to a number
  static final Map<Priority, int> _priorityLevel = {
    Priority.HIGH: 3,
    Priority.MIDDLE: 2,
    Priority.LOW: 1,
    Priority.NONE: 0,
  };
  ///Each event has its [id] to be indentified
  int id;
  ///Event's name
  String taskName;
  ///The date that the [Event] is due
  DateTime ddl;
  ///Each clock is set to be 1500 seconds
  int clockLen = 1500;
  ///The time duration reach [Event] is expected
  int duration = 0;
  ///A category that the [Event] belongs to
  int tag;
  ///Indicator for whether the [Event] repeats everyday
  bool repeat;
  ///The [Event]'s priority level
  Priority eventPriority = Priority.NONE;
  ///List of all the [Subevent] this [Event] has
  ///
  ///This list includes sample [Subevent]
  List subeventsList = <Subevent> [
    new Subevent(subeventName: 'sub1')
  ];
  ///bool isExpanded = false;
  
  Event({this.id,this.taskName,this.ddl,this.eventPriority, this.tag});

  ///Number of clocks each event needs
  int get clockNum => (duration/clockLen).ceil();

  ///Returns the event that has higher priority
  Event higherPriority(Event other) {
    if (_priorityLevel[this.eventPriority] >= _priorityLevel[other.eventPriority]) {
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
  int id;
  String subeventName;
  DateTime subeventDdl;
  int subeventLen = 0;

  Subevent({this.id, this.subeventName, this.subeventDdl});
}
