import 'package:flutter/material.dart';

///Splits priotity into three levels
enum Priority { HIGH, MIDDLE, LOW, NONE }

class ConstantHelper {
  static final Color tomatoColor = Color.fromRGBO(255, 99, 71, 1);

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
