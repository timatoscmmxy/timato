import 'package:flutter/material.dart';

import 'package:timato/core/event.dart';

///Splits priotity into three levels
enum Priority { HIGH, MIDDLE, LOW, NONE }

class ConstantHelper {
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
