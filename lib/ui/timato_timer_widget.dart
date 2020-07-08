import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:timato/core/notifications.dart';
import 'package:timato/core/timato_timer.dart';

enum ButtonStatus {normal, next, end}

enum TimerStatus {normal, relax}

// ignore: must_be_immutable
class TimatoTimerWidget extends StatelessWidget{
  static final _time = ValueNotifier("00:00:00");
  static final _textColor = ValueNotifier(Colors.black);
  static final _buttonColor = ValueNotifier(Colors.amber);
  static final _buttonIcon = ValueNotifier(Icons.play_arrow);
  static final _buttonStatus = ValueNotifier(ButtonStatus.normal);

  static int _timerNum;
  static ValueNotifier<int> usedTimerNum;
  static int _relaxTime;

  static var status = TimerStatus.normal;

  static void _onData(int count) async{
    _time.value = _secondToString(count);
    if (count <= 0){
      if (-count > _relaxTime){
        if (status == TimerStatus.relax) {
          await notifications.show (0, "TimatoEvent", "Relax End!", notificationDetails);
          status = TimerStatus.normal;
        }
        _textColor.value = Colors.deepOrange;
        _buttonColor.value = Colors.deepOrange;
      } else{
        if (status == TimerStatus.normal) {
          await notifications.show (0, "TimatoEvent", "Relax Time!", notificationDetails);
          status = TimerStatus.relax;
        }
        _textColor.value = Colors.lightGreen;
        _buttonColor.value = Colors.lightGreen;
      }
      _buttonIcon.value = Icons.navigate_next;
      _buttonStatus.value = ButtonStatus.next;
    } else{
      _textColor.value = Colors.black;
      _buttonColor.value = Colors.amber;
      _buttonStatus.value = ButtonStatus.normal;
      if (_buttonIcon.value != Icons.play_arrow && _buttonIcon.value != Icons.pause){
        _buttonIcon.value = Icons.play_arrow;
      }
    }
  }

  TimatoTimer _timer;

  TimatoTimerWidget(int timerLength, int relaxLength) {
    _textColor.value = Colors.black;
    _buttonColor.value = Colors.lightBlue;
    _buttonIcon.value = Icons.play_arrow;
    _buttonStatus.value = ButtonStatus.normal;

    _timer = TimatoTimer(timerLength, _onData);
    _timerNum = 2;
    usedTimerNum = ValueNotifier(0);
    _relaxTime = relaxLength;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ValueListenableBuilder(
              valueListenable: _time,
              builder: (BuildContext context, String value, Widget child) {
                return TimerText(_time, _textColor);
              },
            ),
            Center(
              child: ValueListenableBuilder(
                valueListenable: usedTimerNum,
                builder: (BuildContext context, int value, Widget child){
                  return Text(
                    "$value/$_timerNum",
                    style: TextStyle(
                        fontSize: 30,
                        color: Colors.black38
                    ),
                  );
                },
              )
            ),
          ],
        ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Container(
          height: 50.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.error_outline, color: Colors.black38),
                onPressed: () {
                  print("yeah");
                },
              ),
              Expanded(
                child: Container()
              ),
              IconButton(
                icon: Icon(Icons.flag, color: Colors.black38),
                onPressed: () {
                  print("yeah");
                },
              ),
            ],
          )
        ),
        elevation: 20,
      ),
      floatingActionButton: ValueListenableBuilder(
        valueListenable: _buttonColor,
        builder : (BuildContext context, Color value, Widget child){
          return StartButton(_timer, _buttonIcon, _buttonColor, _buttonStatus);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  static String _secondToString(int timerCounter){
    if (timerCounter < 0){
      timerCounter = -timerCounter;
    }
    var result = "";
    if (timerCounter < 0 || timerCounter >= 360000 - 1){
      result = "00:00:00";
    }
    else{
      var hour = (timerCounter ~/ 3600).toString().padLeft(2, '0');
      var minute = ((timerCounter % 3600) ~/ 60).toString().padLeft(2, '0');
      var second = ((timerCounter % 3600) % 60).toString().padLeft(2, '0');
      result = "$hour:$minute:$second";
    }
    return result;
  }
}

class TimerText extends StatelessWidget{
  final ValueListenable<String> time;
  final ValueListenable<Color> color;

  TimerText(this.time, this.color);

  @override
  Widget build(BuildContext context) {
    return Text(
        time.value,
        style: TextStyle(
          fontSize: 60,
          color: color.value
        ),
    );
  }
}

class StartButton extends StatelessWidget{
  final TimatoTimer timer;
  final ValueNotifier<IconData> icon;
  final ValueListenable<Color> color;
  final ValueListenable<ButtonStatus> status;

  var started = false;

  StartButton(this.timer, this.icon, this.color, this.status);

  @override
  Widget build(BuildContext context) {
      return FloatingActionButton(
        onPressed: () {
          if (status.value == ButtonStatus.normal){
            if (started){
              timer.stop();
              started = false;
              icon.value = Icons.play_arrow;
            } else{
              timer.start();
              started = true;
              icon.value = Icons.pause;
            }
          } else if (status.value == ButtonStatus.next){
            ++TimatoTimerWidget.usedTimerNum.value;
            timer.stop();
            timer.restore();
          } else if (status.value == ButtonStatus.end){
            ++TimatoTimerWidget.usedTimerNum.value;
            timer.stop();
            timer.restore();
          }
        },
        child: ButtonIcon(icon),
        elevation: 10,
        backgroundColor: color.value,
      );
  }
}

class ButtonIcon extends StatelessWidget{
  final ValueListenable<IconData> icon;

  ButtonIcon(this.icon);
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: icon,
      builder: (BuildContext context, IconData value, Widget child){
        return Icon(value);
      },
    );
  }
}

getTimerData() async{
  SharedPreferences pref = await SharedPreferences.getInstance();
  return [pref.getInt('timerLength') ?? 25*60, pref.getInt('relaxLength') ?? 25*60];
}