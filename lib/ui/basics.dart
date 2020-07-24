import 'package:flutter/material.dart';

import 'package:time_machine/time_machine.dart';

import 'package:timato/core/event.dart';
import 'package:timato/ui/main_list.dart';
import 'package:timato/ui/today_task_list.dart';

List<Event> todayEventList = [];

///Splits priotity into three levels
enum Priority { HIGH, MIDDLE, LOW, NONE }

class ConstantHelper {
  static final Map intToMonth = {
    1 : 'Jan',
    2 : 'Feb',
    3 : 'Mar',
    4 : 'Apr',
    5 : 'May',
    6 : 'Jun',
    7 : 'Jul',
    8 : 'Aug',
    9 : 'Sep',
    10 : 'Oct',
    11 : 'Nov',
    12 : 'Dec'
  };

  static final Map dayOfWeekToRFC = {
    DayOfWeek.monday : 'MO',
    DayOfWeek.tuesday : 'TU',
    DayOfWeek.wednesday : 'WE',
    DayOfWeek.thursday : 'TH',
    DayOfWeek.friday : 'FR',
    DayOfWeek.saturday : 'SA',
    DayOfWeek.sunday : 'SU',
  };

  static final Color tomatoColor = Color.fromRGBO(255, 99, 71, 1);

  ///Changes the color according to [eventPriority] of [Event]
  static Color priorityColor(AbstractEvent task) {
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

  static final Map<String, Priority> priorityEnum = {
    'High': Priority.HIGH,
    'Middle': Priority.MIDDLE,
    'Low': Priority.LOW,
    'None': Priority.NONE
  };

  static final Map<Priority, String> priorityString = {
    Priority.HIGH: 'High',
    Priority.MIDDLE: 'Middle',
    Priority.LOW: 'Low',
    Priority.NONE: 'None'
  };

  static final Map<Priority, int> priorityLevel = {
    Priority.HIGH: 3,
    Priority.MIDDLE: 2,
    Priority.LOW: 1,
    Priority.NONE: 0
  };

  static final Map<int, String> priorityIntString = {
    3: 'High',
    2: 'Middle',
    1: 'Low',
    0: 'None'
  };
  //Fake data for [tag]
  static final List<String> tags = <String>['English', 'Chinese', 'None'];

  //List for priority level
  static final List<String> priorityList = ['High', 'Middle', 'Low', 'None'];
}

class FloatingRaisedButton extends StatelessWidget {
  final void Function() _onPress;
  final String _text;

  FloatingRaisedButton(this._text, this._onPress);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      child: Container(
        child: Text(
          _text,
          style: TextStyle(
            color: ConstantHelper.tomatoColor,
          ),
        ),
        padding: EdgeInsets.only(top: 15, bottom: 15, left: 35, right: 35),
      ),
      onPressed: _onPress,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}

class WarningDialog extends StatelessWidget {
  final String title, text;
  final void Function(BuildContext) action;
  final BuildContext parentContext;

  WarningDialog(this.title, this.text, this.parentContext, this.action);
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: TextStyle(fontSize: 20, color: ConstantHelper.tomatoColor),
        softWrap: true,
        textAlign: TextAlign.left,
      ),
      titlePadding: EdgeInsets.all(20),
      content: Text(text),
      actions: <Widget>[
        FlatButton(
          child: Text(
            'Cancel',
            style: TextStyle(color: Colors.black38),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        FlatButton(
          child: Text(
            'Confirm',
            style: TextStyle(color: ConstantHelper.tomatoColor),
          ),
          onPressed: () {
            action(parentContext);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  static show(
      {@required String title,
      @required String text,
      @required BuildContext context,
      @required void Function(BuildContext) action}) {
    showDialog(
        context: context,
        builder: (_) => WarningDialog(title, text, context, action),
        barrierDismissible: true);
  }
}

class SideBar extends StatelessWidget {
  SideBar(this.pageName);
  final String pageName;

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(children: <Widget>[
      DrawerHeader(
          child: Text('Timato, be productive with you'),
          decoration: BoxDecoration(color: ConstantHelper.tomatoColor)),
      ListTile(
          title: Text('My Tasks'),
          onTap: () {
            if(pageName == 'MyTask'){
              Navigator.pop(context);
            }else{
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) {
              return MyTask();
            }));}
          }),
      ListTile(
          title: Text("Today's Tasks"),
          onTap: () {
            if(pageName == 'TodayList'){
              Navigator.pop(context);
            }else{
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) {
              return TodayList();
            
            }));}
          }),
      ListTile(
          title: Text("Completed Task"),
          onTap: () {
            // Navigator.push(context,MaterialPageRoute(builder:(_){
            //   return CompletedTaskPage();
            // }));
          }),
    ]));
  }
}

class TimerLengthAlert extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Invalid number input',
        style: TextStyle(
            fontSize: 14
        ),
        softWrap: true,
        textAlign: TextAlign.left,
      ),
      titlePadding: EdgeInsets.all(10),
      content: Text('Value input must be between 0 and 5940 minutes'),
      actions: <Widget>[
        FlatButton(
          child: Text(
            'OK',
            style: TextStyle(
                color: Colors.lightBlue
            ),
          ),
          onPressed: (){
            Navigator.pop(context);
          },
        )
      ],
    );
  }

  static show(BuildContext context){
    showDialog(context: context, builder: (_) => TimerLengthAlert(), barrierDismissible: true);
  }
}

int getWeekNum(LocalDate date) {
  LocalDate firstDay = LocalDate(date.year, date.monthOfYear, 1);
  LocalDate lastDay = LocalDate(date.year, date.monthOfYear + 1, 1).subtractDays(1);
  int firstSunday = 1 + (7 - firstDay.dayOfWeek.value);
  int lastMonday = 31 - lastDay.dayOfWeek.value + 1;
  if (date.dayOfMonth <= firstSunday) {
    return 1;
  } else if (date.dayOfMonth <= firstSunday + 7) {
    return 2;
  } else if (date.dayOfMonth <= firstSunday + 14) {
    return 3;
  } else if (date.dayOfMonth <= firstSunday + 21) {
    if (date.dayOfMonth >= lastMonday) {
      return -1;
    } else {
      return 4;
    }
  } else {
    return -1;
  }
}
