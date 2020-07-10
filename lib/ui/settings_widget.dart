import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:timato/ui/basics.dart';

class Settings extends StatelessWidget{
  final tomatoColor = Color.fromRGBO(255, 99, 71, 1);
  final SharedPreferences _pref;

  int timerLength, relaxLength;
  String language;

  Settings(this._pref){
    timerLength = _pref.getInt('timerLength') ?? 0;
    relaxLength = _pref.getInt('relaxLength') ?? 0;
    language = _pref.getString('language') ?? 'en_US';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {Navigator.pop(context);},
        ),
      ),
      body: ListView(
        children: <Widget>[
          TextSetting('Timer Duration', timerLength, (val) => timerLength = val * 60),
          TextSetting('Relax Time', relaxLength, (val) => relaxLength = val * 60),
        ],
      ),
      floatingActionButton: FloatingRaisedButton(
        'Done',
              (){
            _pref.setInt('timerLength', timerLength);
            _pref.setInt('relaxLength', relaxLength);
            Navigator.pop(context);
          }
      ),
    );
  }
}

class TextSetting extends StatelessWidget{
  final String _text;
  final int _value;
  final void Function(int) _onChange;

  TextSetting(this._text, this._value, this._onChange);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListTile(
        title: Row(
          children: <Widget>[
            Expanded(
              child: Container(
                child: Text(
                  '$_text: ',
                  style: TextStyle(
//                  fontSize: 20,
                  ),
                ),
                padding: EdgeInsets.all(10),
              ),
            ),
            Expanded(
              child: Container(
                child: TextField(
                  decoration: InputDecoration(
                      hintText: 'Current: ${_value ~/ 60} (minutes)'
                  ),
                  onChanged: (String text){
                    if (text == ''){
                      return;
                    }
                    int val;
                    try{
                      val = int.parse(text);
                    } catch (e){
                      TimerLengthAlert.show(context);
                    }
                    if (val < 0 || val > 5940){
                      TimerLengthAlert.show(context);
                    }
                    _onChange(val);
                  },
                )
              ),
            )
          ],
        ),
        contentPadding: EdgeInsets.all(5),
      ),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.black12,
            style: BorderStyle.solid,
            width: 1
          )
        )
      ),
    );
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