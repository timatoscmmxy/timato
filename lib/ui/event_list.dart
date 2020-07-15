import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:timato/core/event.dart';
import 'package:timato/ui/basics.dart';
import 'package:timato/ui/main_list.dart';

//Fake data for [Event]
Event task1 = new Event(
    taskName: '背单词',
    ddl: DateTime.now(),
    eventPriority: Priority.NONE,
    tag: 'English',
    numClock: 3);

//List<int> hours = <int>[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16];
//for (int i = 0, i <= 99, i++)=>hours.add(i);

class MyApp2 extends StatelessWidget {
  ///newly added
  //const MyApp1({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: EventList(task: task1),
    );
  }
}

class EventList extends StatefulWidget {
  EventList({Key key, this.task}) : super(key: key);
  final Event task;

  @override
  _EventListState createState() => _EventListState();
}

class _EventListState extends State<EventList> {
  // static final Color tomatoColor = Color.fromRGBO(255, 99, 71, 1);

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
                icon: Icon(
                  Icons.delete,
                  color: ConstantHelper.tomatoColor,
                ),
                onPressed: () {
                  Navigator.pop(context);
                }),
            IconButton(
                icon: Icon(
                  Icons.check,
                  color: ConstantHelper.tomatoColor,
                ),
                onPressed: () {
                  Navigator.pop(context);
                }),
          ]),
      body: _eventDetail(task1),
      floatingActionButton: FloatingRaisedButton('Start clock', () {
        Navigator.pop(context);
      }),
    );
  }
}

///Builds the page for all the infomations of an [Event]
Widget _eventDetail(Event task) {
  return ListView(children: <Widget>[
    TextName(task: task),
    TaskTag(task: task),
    TaskDate(task: task),
    // Container(
    //   child: Row(
    //     children:<Widget>[
    //       SizedBox(width:13),
    //       Icon(Icons.timer),
    //Container(
    // ClockNumber(task:task)
    //),

    // )
    // ),
    TaskPriority(task: task),
    SizedBox(height:10),
    ClockNumber(task: task)
    //SubtaskList(task: task)
    //ClockNumber(task:task)
    //TaskPriority()
    // Container(
    //     child: Row(children: <Widget>[
    //   SizedBox(width: 12),
    //   Icon(Icons.timer),
    //   SizedBox(width: 12),
    //   //ClockNumber(number:'3'),
    // ])
    //     // SubTasks(task.subeventsList)
    //     )
  ]);
}

///Shows the name of the [Event]
///
///Users can change the name of the [Event]
// class TextName extends StatelessWidget {
//   final String _name;

//   TextName(this._name);

//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       textInputAction: TextInputAction.done,
//       maxLength: 25,
//       initialValue: _name,
//       decoration: const InputDecoration(
//         prefix: Text('   '),
//       ),
//     );
//   }
// }

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
      maxLength: 25,
      initialValue: this.task.taskName,
      decoration: const InputDecoration(
        counterText: '',
        border: InputBorder.none,
        prefix: Text('   '),
      ),
    ));
  }
}

///Selects a tag for each [Event]
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
      Icon(Icons.label_outline, color: ConstantHelper.tomatoColor,),
      SizedBox(width: 12),
      DropdownButton<String>(
        //hint: Text("Select a tag"),
        value: this.task.tag,
        onChanged: (String value) {
          setState(() {
            this.task.tag = value;
          });
        },
        items: ConstantHelper.tags.map((tag) {
          return DropdownMenuItem<String>(
              value: tag,
              child: Row(children: <Widget>[
                Text(
                  tag,
                  style: TextStyle(fontSize: 14),
                )
              ]));
        }).toList(),
      )
    ]));
  }
}

///Sets the due day for the [Event]
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
        initialDate: this.task.ddl,
        firstDate: DateTime.now(),
        lastDate: DateTime(2200));
    if (picked != null && picked != this.task.ddl)
      setState(() {
        // developer.log(picked.toString());
        // developer.log(task1.ddl.toString());
        this.task.ddl = picked;
        //TODO save data in database
      });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Row(children: <Widget>[
      IconButton(
          icon: Icon(Icons.calendar_today, color: ConstantHelper.tomatoColor),
          onPressed: () => _selectDate(context)),
      Text("${this.task.ddl.toLocal()}".split(' ')[0]),
    ]));
  }
}

///Set priority for each [Event]
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
        Icon(Icons.brightness_1, color: _priorityColor(task)),
        SizedBox(width: 12),
        DropdownButton<String>(
          //hint: Text("Select priority level"),
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

  Color _priorityColor(Event task) {
    if (task.eventPriority == Priority.HIGH) {
      return Color.fromRGBO(202, 45, 45, 1);
    } else if (task.eventPriority == Priority.MIDDLE) {
      return Color.fromRGBO(236, 121, 121, 1);
    } else if (task.eventPriority == Priority.LOW) {
      return Color.fromRGBO(255, 191, 191, 1);
    } else {
      return Colors.white;
    }
  }

  // Color _subpriorityColor(Subevent subtask) {
  //   if (subtask.subeventPriority == Priority.HIGH) {
  //      return Color.fromRGBO(202, 45, 45, 1);
  //   } else if (subtask.subeventPriority == Priority.MIDDLE) {
  //     return Color.fromRGBO(236, 121, 121, 1);
  //   } else if (subtask.subeventPriority == Priority.LOW) {
  //     return Color.fromRGBO(255, 191, 191, 1);
  //   } else {
  //     return Colors.white;
  //   }
  // }
}

// class TimeHour extends StatefulWidget {
//   @override
//   _TimeHourState createState() => _TimeHourState();
// }

// class _TimeHourState extends State<TimeHour> {
//   int _hour = 0;
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: Row(
//         children: <Widget>[
//           Icon(Icons.timer),
//           SetHour(hour, (val) => hour = val, 'hour(s)'),
//           SetMinute(minute, (val) => minute = val, 'minute')
//         ],)
//     );
//   }
// }

// class SetHour extends StatelessWidget {
//   final String _text;
//   final int _hour;
//   final void Function(int) _onChange;

//   SetHour(this._hours, this.onChange, this._text);
// }

// class TaskLength extends StatelessWidget {
//   final String _number;

//   TaskLength(this._number);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//         child: Row(children: <Widget>[
//           Icon(Icons.timer),
//           TextFormField(
//             keyboardType: TextInputType.number,
//             inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
//             maxLength: 3,
//             initialValue: _number,
//             decoration: const InputDecoration(
//               prefix: Text('   '),
//             ),
//           ),
//           //Text('')
//     ]));
//   }
// }

class ClockNumber extends StatefulWidget {
  ClockNumber({Key key, this.task}) : super(key: key);
  final Event task;

  @override
  _ClockNumberState createState() => _ClockNumberState(task);
}

class _ClockNumberState extends State<ClockNumber> {
  _ClockNumberState(this.task);
  final Event task;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Row(children: <Widget>[
      SizedBox(width: 12),
      Icon(Icons.timer, color: ConstantHelper.tomatoColor),
      SizedBox(width: 12),
      Container(
          width: 50,
          height: 20,
          child: TextFormField(
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
            maxLength: 3,
            decoration: const InputDecoration(counterText: '',border: InputBorder.none),
            initialValue: this.task.numClock.toString(),
            onChanged: (text) {
              this.task.numClock = int.parse(text);
              print('$this.task.numClock');
            },
            // decoration: const InputDecoration(
            //   prefix: Text('   '),
            // ),
          ))
    ]));
    //Text('');
  }
}

/*
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
    return Container(
        height: 45.5 * (task.subeventsList.length + 1),
        child: Row(
          children: <Widget>[Icon(Icons.subject), _sublist(task)],
        ));
  }

  Widget _sublist(Event task) {
    return ListView(children: <Widget>[
      ListView(
        children: this.task.subeventsList.map((subtask) {
          return Slidable(
              key: Key(subtask.id.toString()),
              actionPane: SlidableDrawerActionPane(),
              actionExtentRatio: 0.25,
              secondaryActions: <Widget>[
                IconSlideAction(color: tomatoColor, icon: Icons.add

                    ///Needs onTop in the future
                    ),
                IconSlideAction(color: tomatoColor, icon: Icons.delete)
              ],
              child: SublistDetail(subtask: subtask));
        }).toList(),
      ),
      TextFormField(
        onChanged: (text) {
          Subevent sub = new Subevent(subeventName: text);
          this.task.subeventsList.add(sub);
          SubtaskList(task: task);
        },
        textInputAction: TextInputAction.done,
        maxLength: 15,
        decoration: InputDecoration(hintText: 'add a subtask...'),
      )
    ]);
  }
  */

// Widget _sublistDetail(Subevent subtask) {
//   var _checkValue = false;
//   return Row(
//     children: <Widget>[
//       Checkbox(
//           value: _checkValue,
//           onChanged: (value) {
//             setState(() {
//               _checkValue = value;
//             });
//           }),
//       Container(
//       child: TextFormField(
//         onChanged: (text) {
//         this.subtask.subeventName = text;
//       print('$this.task.taskName');
//     },
//     textInputAction: TextInputAction.done,
//     maxLength: 25,
//     initialValue: this.task.taskName,
//     decoration: const InputDecoration(
//       prefix: Text('   '),
//     ),
//   ))
//     ],
//   );
// }
// }

/*
class SublistDetail extends StatefulWidget {
  SublistDetail({Key key, this.subtask}) : super(key: key);
  final Subevent subtask;
  @override
  _SublistDetailState createState() => _SublistDetailState(subtask);
}

class _SublistDetailState extends State<SublistDetail> {
  _SublistDetailState(this.subtask);
  final Subevent subtask;

  @override
  Widget build(BuildContext context) {
    var _checkValue = false;
    return Container(
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
            child: TextFormField(
          onChanged: (text) {
            this.subtask.subeventName = text;
            print('$this.task.taskName');
          },
          textInputAction: TextInputAction.done,
          maxLength: 25,
          initialValue: this.subtask.subeventName,
          decoration: const InputDecoration(
            prefix: Text('   '),
          ),
        ))
      ],
    ));
  }
}*/
