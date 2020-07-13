import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

import 'package:timato/core/event.dart';
import 'package:timato/ui/basics.dart';
import 'dart:developer' as developer;

//Fake data for [tag]
List<String> tags = <String>['English', 'Chinese', 'None'];

//Fake data for [Event]
Event task1 = new Event(
    id: 0, taskName: '背单词', ddl: DateTime.now(), eventPriority: Priority.NONE, tag: 'English', numClock: 3);

//List<int> hours = <int>[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16];
//for (int i = 0, i <= 99, i++)=>hours.add(i);

class MyApp2 extends StatelessWidget {
  ///newly added
  //const MyApp1({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: EventList(),
    );
  }
}

class EventList extends StatefulWidget {
  @override
  _EventListState createState() => _EventListState();
}

class _EventListState extends State<EventList> {
  // //Fake data for [Event]
  // Event task1 = new Event(
  //     id: 0, taskName: tags[2], eventPriority: Priority.NONE, tag: 'English');

  static final Color tomatoColor = Color.fromRGBO(255, 99, 71, 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: tomatoColor),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: <Widget>[
            IconButton(
                icon: Icon(
              Icons.delete,
              color: tomatoColor,
            )),
            IconButton(
                icon: Icon(
              Icons.check,
              color: tomatoColor,
            )),
          ]),
      body: _eventDetail(task1),
      floatingActionButton: FloatingRaisedButton('Start clock', (){
        Navigator.pop(context);
      }),
    );
  }
}

///Builds the page for all the infomations of an [Event]
Widget _eventDetail(Event task) {
  return ListView(children: <Widget>[
    TextName(task.taskName),
    Container(
        child: Row(children: <Widget>[
      SizedBox(width: 12),
      Icon(Icons.label_outline),
      SizedBox(width: 12),
      TaskTag(),
    ])),
    TaskDate(),
    //TaskPriority()
    Container(
      child: Row(children: <Widget>[
      SizedBox(width: 12),
      Icon(Icons.timer),
      SizedBox(width: 12),
      //ClockNumber(number:'3'),

      ]
    )
    // SubTasks(task.subeventsList)
  )]);
}

///Shows the name of the [Event]
///
///Users can change the name of the [Event]
class TextName extends StatelessWidget {
  final String _name;

  TextName(this._name);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textInputAction: TextInputAction.done,
      maxLength: 25,
      initialValue: _name,
      decoration: const InputDecoration(
        prefix: Text('   '),
      ),
    );
  }
}

///Selects a tag for each [Event]
class TaskTag extends StatefulWidget {
  @override
  _TaskTagState createState() => _TaskTagState();
}

class _TaskTagState extends State<TaskTag> {
  String tag;
  @override
  Widget build(BuildContext context) {
    return Container(
        child: DropdownButton<String>(
      hint: Text("Select a tag"),
      value: tag,
      onChanged: (String Value) {
        setState(() {
          tag = Value;
        });
      },
      items: tags.map((tag) {
        return DropdownMenuItem<String>(
            value: tag,
            child: Row(children: <Widget>[
              Text(
                tag,
                style: TextStyle(fontSize: 14),
              )
            ]));
      }).toList(),
    ));
  }
}

///Sets the due day for the [Event]
class TaskDate extends StatefulWidget {
  TaskDate({Key key, this.task}) : super(key: key);

  final Event task;
  @override
  _TaskDateState createState() => _TaskDateState();
}

class _TaskDateState extends State<TaskDate> {
  DateTime selectedDate = task1.ddl;

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime.now(),
        lastDate: DateTime(2200));
    if (picked != null && picked != selectedDate)
      setState(() {
        // developer.log(picked.toString());
        // developer.log(task1.ddl.toString());
        task1.ddl = picked;
        //TODO save data in database
      });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Row(children: <Widget>[
      IconButton(
          icon: Icon(Icons.calendar_today),
          onPressed: () => _selectDate(context)),
      Text("${selectedDate.toLocal()}".split(' ')[0]),
    ]));
  }
}

///Set priority for each [Event]
/*class TaskPriority extends StatefulWidget {
  @override
  _TaskPriorityState createState() => _TaskPriorityState();
}

class _TaskPriorityState extends State<TaskPriority> {
  Priority priorityLevel = task1.eventPriority;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: DropdownButton<String>(
        hint: Text("Select priority level"),
        value: priorityLevel.toString(),
        onChanged: (Priority Value) {
          setState((){
            priorityLevel = Value;
          });
        },
        items: _priorityLevel((Priority) {
          return DropdownMenuItem<Priority>(
            value: priorityLevel,
            child: Row(
              children: <Widget>[
                Text(priorityLevel.toString(), style: TextStyle(fontSize: 14),
            )
              ]
              ));
        }).toList(),
      )
    );
  }
}*/

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

/*class ClockNumber extends StatefulWidget {
  ClockNumber({Key key, this.number}) : super(key:key);
  final String number;

  @override
  _ClockNumberState createState() => _ClockNumberState();
}

class _ClockNumberState extends State<ClockNumber> {
  //int init = 1;
  @override
  Widget build(BuildContext context) {
    // return Container(
    //   child: Row(children: <Widget>[
    //       Icon(Icons.timer),
          return TextFormField(
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
            maxLength: 3,
            //initialValue: ,
            decoration: const InputDecoration(
              prefix: Text('   '),
            ),
          );
          //Text('');
  }
}*/
