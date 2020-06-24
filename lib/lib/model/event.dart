class Event{
  String taskName;
  DateTime ddl;
  int numClock;
  int clockLen;
  int duration;
  int tag;
  bool repeat;

  Event(String inputName){
    this.taskName = inputName;
    this.ddl = null;
    this.numClock = 0;
    this.duration = 0;
    this.tag = null;
    this.repeat = null;
    this.clockLen = 25;
  }

  void changeName(String newName){
    this.taskName = newName;
  }

  void setDdl(DateTime newDdl){
    this.ddl = newDdl;
  }

  void setDuration(int newDuration){
    this.duration = newDuration;
    this.numClock = (this.duration/clockLen) as int;
  }

  void setClockLen(int newClockLen){
    this.clockLen = newClockLen;
    this.numClock = (this.duration/clockLen) as int;
  }

  void setRepeat(bool newRepeat){
    this.repeat = newRepeat;
  }
}