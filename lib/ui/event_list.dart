import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:timato/core/event.dart';
import 'package:timato/core/event_repository.dart';
import 'package:timato/ui/basics.dart';
import 'package:timato/core/db.dart';
import 'package:timato/ui/timato_timer_widget.dart';
import 'package:timato/ui/main_list.dart';

//Fake data for [Event]
// Event task1 = new Event(
//     taskName: '背单词',
//     ddl: DateTime.now(),
//     eventPriority: Priority.NONE,
//     tag: 'English');

// class MyApp2 extends StatelessWidget {

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: EventList(task: task1),
//     );
//   }
// }

class EventList extends StatefulWidget {
  EventList({Key key, this.task, this.page}) : super(key: key);
  final Event task;
  final String page;

  @override
  _EventListState createState() => _EventListState(task:task,page:page);
}

class _EventListState extends State<EventList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  _EventListState({this.task, this.page});
  final Event task;
  final String page;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: ConstantHelper.tomatoColor),
              onPressed: () {
                Navigator.pop(context);
              }),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.delete, color: ConstantHelper.tomatoColor),
              // onPressed: () => {

              //   Navigator.pop(context),
              //   databaseHelper.deleteEvent(task.id),
              //   MainList()
              //   // databaseHelper.getNoteList().then((data) {
              //   //   eventsList = data;
              //   //   MainList();
              //   // })
              // },
            ),
            // IconButton(
            //     icon: Icon(
            //       Icons.check,
            //       color: ConstantHelper.tomatoColor,
            //     ),
            //     onPressed: () {
            //       Navigator.pop(context);
            //     }),
          ]),
      body: _eventDetail(task),
      floatingActionButton: 
        _button(page),
      // FloatingRaisedButton('Start clock', () async {
      //   List<int> timerData = await getTimerData();
      //   int timerLength = timerData[0];
      //   int relaxLength = timerData[1];
      //   int currentClockNum = await task.clockNum;
      //   Navigator.push(context, MaterialPageRoute(builder: (_) {
      //     return TimatoTimerWidget(
      //         timerLength: timerLength,
      //         relaxLength: relaxLength,
      //         event: task,
      //         clockNum: currentClockNum);
      //   }));
      // }),
    );
  }

  FloatingRaisedButton _button(String page){
    if(page=='mainList'){
      return FloatingRaisedButton('Done', () async {
        // List<int> timerData = await getTimerData();
        // int timerLength = timerData[0];
        // int relaxLength = timerData[1];
        // int currentClockNum = await task.clockNum;
        Navigator.pop(context);
      });
    }else{
      return FloatingRaisedButton('Start clock', () async {
        List<int> timerData = await getTimerData();
        int timerLength = timerData[0];
        int relaxLength = timerData[1];
        int currentClockNum = await task.clockNum;
        Navigator.push(context, MaterialPageRoute(builder: (_) {
          return TimatoTimerWidget(
              timerLength: timerLength,
              relaxLength: relaxLength,
              event: task,
              clockNum: currentClockNum);
        }));
      });
    }
  }
}

///Builds the whole event page
///
///Event page contains all the details that delong to the [Event]
///Including: [taskName], [id], [ddl], [eventPriority], [subeventsList]
Widget _eventDetail(Event task) {
  return ListView(children: <Widget>[
    TextName(task: task),
    TaskTag(task: task),
    TaskDate(task: task),
    TaskPriority(task: task),
    SizedBox(height: 10),
    TaskDuration(task: task),
    SubtaskList(task: task)
  ]);
}

///Builds the part for [taskName]
///
///Users can modify [taskName] on this page
class TextName extends StatefulWidget {
  TextName({Key key, this.task}) : super(key: key);
  final Event task;
  @override
  _TextNameState createState() => _TextNameState(task);
}

class _TextNameState extends State<TextName> {
  _TextNameState(this.task);
  final Event task;
  @override
  Widget build(BuildContext context) {
    return Container(
        child: TextFormField(
      onChanged: (text) {
        this.task.taskName = text;
        print('$this.task.taskName');
      },
      textInputAction: TextInputAction.done,
      maxLength: 20,
      initialValue: this.task.taskName,
      decoration: const InputDecoration(
        counterText: '',
        border: InputBorder.none,
        prefix: Text('   '),
      ),
    ));
  }
}

///Builds the part for [id]
///
///Users select a tag for this [Event] from the list of tags
class TaskTag extends StatefulWidget {
  TaskTag({Key key, this.task}) : super(key: key);
  final Event task;
  @override
  _TaskTagState createState() => _TaskTagState(task);
}

class _TaskTagState extends State<TaskTag> {
  _TaskTagState(this.task);
  final Event task;
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Row(children: <Widget>[
      SizedBox(width: 12),
      Icon(Icons.label_outline, color: ConstantHelper.tomatoColor),
      // SizedBox(width: 12),
      Container(
          width: 166,
          child: TextFormField(
            onChanged: (text) {
              this.task.tag = text;
              //TODO: store
              print('$this.task.tag');
            },
            textInputAction: TextInputAction.done,
            maxLength: 10,
            initialValue: _tagString(task),
            style: TextStyle(fontSize: 14),
            // this.task.taskName,
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              prefix: Text('   '),
            ),
          ))
    ]));
  }

  String _tagString(Event task) {
    if (this.task.tag != null) {
      return this.task.tag.toString();
    } else {
      return "enter a tag";
    }
  }
}

///Builds the part for [ddl]
class TaskDate extends StatefulWidget {
  TaskDate({Key key, this.task}) : super(key: key);
  final Event task;
  @override
  _TaskDateState createState() => _TaskDateState(task);
}

class _TaskDateState extends State<TaskDate> {
  _TaskDateState(this.task);
  final Event task;

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2200));
    if (picked != null && picked != this.task.ddl)
      setState(() {
        this.task.ddl = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Row(children: <Widget>[
      IconButton(
          icon: Icon(Icons.calendar_today, color: ConstantHelper.tomatoColor),
          onPressed: () => _selectDate(context)),
      Text((() {
        if (this.task.ddl != null) {
          return "${this.task.ddl.toLocal()}".split(' ')[0];
        } else {
          return "select a date";
        }
      })()),
    ]));
  }
}

///Builds the part for [eventPriority]
///
///Users select a priority level for this [Event]
class TaskPriority extends StatefulWidget {
  TaskPriority({Key key, this.task}) : super(key: key);
  final Event task;
  @override
  _TaskPriorityState createState() => _TaskPriorityState(task);
}

class _TaskPriorityState extends State<TaskPriority> {
  _TaskPriorityState(this.task);
  final Event task;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Row(
      children: <Widget>[
        SizedBox(width: 12),
        Icon(Icons.brightness_1, color: ConstantHelper.priorityColor(task)),
        SizedBox(width: 12),
        DropdownButton<String>(
          value: ConstantHelper.priorityString[this.task.eventPriority],
          onChanged: (String priority) {
            setState(() {
              Priority value = ConstantHelper.priorityEnum[priority];
              this.task.eventPriority = value;
            });
          },
          items: ConstantHelper.priorityList.map((priority) {
            return DropdownMenuItem<String>(
                value: priority,
                child: Row(children: <Widget>[
                  Text(
                    priority,
                    style: TextStyle(fontSize: 14),
                  )
                ]));
          }).toList(),
        )
      ],
    ));
  }
}

///Builds the part for [duration]
///
///Users input the duration for this [task]
class TaskDuration extends StatefulWidget {
  TaskDuration({Key key, this.task}) : super(key: key);
  final Event task;

  @override
  _TaskDurationState createState() => _TaskDurationState(task);
}

class _TaskDurationState extends State<TaskDuration> {
  _TaskDurationState(this.task);
  final Event task;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Row(children: <Widget>[
      SizedBox(width: 12),
      Icon(Icons.timer, color: ConstantHelper.tomatoColor),
      SizedBox(width: 12),
      Container(
          width: 166,
          child: TextFormField(
            // keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
            maxLength: 3,
            decoration: const InputDecoration(
                hintText: 'It might take ...',
                suffixText: 'minutes',
                counterText: '',
                border: InputBorder.none),
            // onChanged: (text)
            onChanged: (String text) {
              if (text == '') {
                return;
              }
              int val;
              try {
                val = int.parse(text);
              } catch (e) {
                TimerLengthAlert.show(context);
              }
              if (val < 0 || val > 5940) {
                TimerLengthAlert.show(context);
              }
              this.task.duration = int.parse(text);
              print('$this.task.duration');
              // _onChange(val);
            },
            // {
            //   this.task.duration = int.parse(text);
            //   print('$this.task.duration');
            // },
          ))
    ]));
  }
}

///Builds [Subevent] list for this [Event]
///
///Users can add [Subevents] to this list
///Checkbox can be checked when a [Subevent] is completed
class SubtaskList extends StatefulWidget {
  SubtaskList({Key key, this.task}) : super(key: key);
  final Event task;
  @override
  _SubtaskListState createState() => _SubtaskListState(task);
}

class _SubtaskListState extends State<SubtaskList> {
  _SubtaskListState(this.task);
  final Event task;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
        height: 35.0 * (task.subeventsList.length + 1) + 20 + 22,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(width: 12),
            Container(
                padding: EdgeInsets.only(top: 15),
                width: 25,
                child: Icon(Icons.subject, color: ConstantHelper.tomatoColor)),
            SizedBox(width: 12),
            Container(
                padding: EdgeInsets.all(10),
                width: size.width - 49,
                height: 35.0 * (task.subeventsList.length + 1) + 20 + 22,
                child: _sublist(task)),
          ],
        ));
  }

  Widget _sublist(Event task) {
    return Column(children: <Widget>[
      SizedBox(height: 22),
      Container(
          //color: Colors.white70,
          height: 35.0 * (task.subeventsList.length),
          width: 326,
          child: ListView(
            physics: NeverScrollableScrollPhysics(),
            children: task.subeventsList.map((subtask) {
              return Slidable(
                  key: subtask.key,
                  actionPane: SlidableDrawerActionPane(),
                  actionExtentRatio: 0.25,
                  secondaryActions: <Widget>[
                    // IconSlideAction(
                    //     color: ConstantHelper.tomatoColor,
                    //     icon: Icons.add
                    //     ),
                    IconSlideAction(
                        color: ConstantHelper.tomatoColor, icon: Icons.delete)
                  ],
                  child: SublistDetail(subtask: subtask));
            }).toList(),
          )),
      Container(
        height: 35,
        width: 326,
        child: TextField(
            // keyboardType: TextInputType.multiline,
            controller: TextEditingController()..text = '',
            onChanged: (text) => {},
            onSubmitted: (text) {
              Subevent sub = new Subevent(taskName: text);
              this.task.subeventsList.add(sub);
              setState(() {});
            },
            textInputAction: TextInputAction.done,
            maxLength: 15,
            decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
                prefix: Text('   '),
                hintText: 'add a subtask...')),
      )
    ]);
  }
}

///Builds details for a [Subevent] on the list
///
///Adds a checkbox in front of each [Subevent]
///Displays the name of the [Subevent]
class SublistDetail extends StatefulWidget {
  SublistDetail({Key key, this.subtask}) : super(key: key);
  final Subevent subtask;
  @override
  _SublistDetailState createState() => _SublistDetailState(subtask);
}

class _SublistDetailState extends State<SublistDetail> {
  _SublistDetailState(this.subtask);
  final Subevent subtask;
  var _checkValue = false;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 35,
        width: 326,
        child: Row(
          children: <Widget>[
            Checkbox(
                value: _checkValue,
                onChanged: (value) {
                  setState(() {
                    _checkValue = value;
                  });
                }),
            Container(
                width: 200,
                height: 35,
                child: TextFormField(
                  onChanged: (text) {
                    subtask.taskName = text;
                    print('$subtask.taskName');
                  },
                  textInputAction: TextInputAction.done,
                  maxLength: 25,
                  initialValue: subtask.taskName,
                  decoration: const InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                    prefix: Text('   '),
                  ),
                ))
          ],
        ));
  }
}
