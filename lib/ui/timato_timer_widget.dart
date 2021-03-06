import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timato/core/completed_repository.dart';
import 'package:timato/core/event_repository.dart';
import 'package:date_format/date_format.dart' as ddlFormat;

import 'package:timato/core/notifications.dart';
import 'package:timato/core/tag_repository.dart';
import 'package:timato/core/timato_timer.dart';
import 'package:timato/core/event.dart';
import 'package:timato/ui/basics.dart';
import 'package:timato/ui/add_event.dart';
import 'package:timato/ui/today_task_list.dart';
import 'package:timato/core/event_repository.dart';

enum ButtonStatus { normal, next, end }

enum TimerStatus { normal, relax }

// ignore: must_be_immutable
class TimatoTimerWidget extends StatelessWidget {
  static final ValueNotifier<String> _time = ValueNotifier("00:00:00");
  static final ValueNotifier<Color> _textColor = ValueNotifier(Colors.black);
  static final ValueNotifier<Color> _buttonColor = ValueNotifier(Colors.amber);
  static final ValueNotifier<IconData> _buttonIcon =
      ValueNotifier(Icons.play_arrow);
  static final ValueNotifier<ButtonStatus> _buttonStatus =
      ValueNotifier(ButtonStatus.normal);

  static int _timerNum;
  static ValueNotifier<int> usedTimerNum;
  static int _relaxTime;

  static TimerStatus _status = TimerStatus.normal;

  final Event event;

  TimatoTimer _timer;

  static BuildContext get context => null;

  static void _onData(int count) async {
    _time.value = secondToString(count);
    if (count <= 0) {
      if (-count > _relaxTime) {
        if (_status == TimerStatus.relax) {
          await notifications.show(
              0,
              "TimatoEvent",
              TimatoLocalization.instance.getTranslatedValue('relax_end'),
              notificationDetails);
          _status = TimerStatus.normal;
        }
        _textColor.value = Colors.deepOrange;
        _buttonColor.value = Colors.deepOrange;
      } else {
        if (_status == TimerStatus.normal) {
          await notifications.show(
              0,
              "TimatoEvent",
              TimatoLocalization.instance.getTranslatedValue('relax_start'),
              notificationDetails);
          _status = TimerStatus.relax;
        }
        _textColor.value = Colors.lightGreen;
        _buttonColor.value = Colors.lightGreen;
      }
      _buttonIcon.value = Icons.navigate_next;
      _buttonStatus.value = ButtonStatus.next;
    } else {
      _textColor.value = Colors.black;
      _buttonColor.value = Colors.white;
      _buttonStatus.value = ButtonStatus.normal;
      if (_buttonIcon.value != Icons.play_arrow &&
          _buttonIcon.value != Icons.pause) {
        _buttonIcon.value = Icons.play_arrow;
      }
    }
  }

  TimatoTimerWidget({
    @required int timerLength,
    @required int relaxLength,
    @required AbstractEvent event,
    int clockNum,
  })  : this._timer = TimatoTimer(timerLength, relaxLength, _onData),
        this.event = event {
    _textColor.value = Colors.black;
    _buttonColor.value = Colors.white;
    _buttonIcon.value = Icons.play_arrow;
    _buttonStatus.value = ButtonStatus.normal;
    _timerNum = clockNum ?? -1;
    usedTimerNum = ValueNotifier(event.usedTimerNum);
    _relaxTime = relaxLength;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          color: ConstantHelper.tomatoColor,
          icon: Icon(Icons.keyboard_backspace),
          onPressed: () {
            _timer.stop();
            Navigator.pop(context, false);
          },
        ),
        title: Text(
          event.taskName,
          maxLines: 1,
          softWrap: false,
          style: TextStyle(color: ConstantHelper.tomatoColor),
        ),
        elevation: 0,
      ),
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
            builder: (BuildContext context, int value, Widget child) {
              return Text(
                "$value/${_timerNum == -1 ? '-' : _timerNum}",
                style: TextStyle(fontSize: 30, color: Colors.black38),
              );
            },
          )),
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
                  icon: Icon(Icons.assistant, color: Colors.black38),
                  onPressed: () {
                    AddEvent.showAddUnplannedEvent(context);
                  },
                ),
                Expanded(child: Container()),
                IconButton(
                  icon: Icon(Icons.check, color: Colors.black38),
                  onPressed: () async {
                    var data = await WarningDialog.show(
                        title: TimatoLocalization.instance
                            .getTranslatedValue('mark_completed_title'),
                        text: TimatoLocalization.instance
                            .getTranslatedValue('mark_completed'),
                        context: context,
                        action: (context) {
                          _timer.stop();
                          DateTime completedDate = DateTime(DateTime.now().year,
                              DateTime.now().month, DateTime.now().day);
                          event.completedDate = ddlFormat.formatDate(
                              completedDate, [
                            ddlFormat.yyyy,
                            '-',
                            ddlFormat.mm,
                            '-',
                            ddlFormat.dd
                          ]);
                          updateTag(event.tag, event.usedTimerNum);
                          insertCompletedEvent(event);
                          if (event.repeatProperties == null) {
                            deleteEvent(event.id);
                          } else {
                            event.isTodayList = 0;
                            updateEvent(event);
                          }
                        });
                    if (data) {
                      Navigator.pop(context, true);
                    }
                  },
                ),
              ],
            )),
        elevation: 20,
      ),
      floatingActionButton: ValueListenableBuilder(
        valueListenable: _buttonColor,
        builder: (BuildContext context, Color value, Widget child) {
          return StartButton(
              _timer, _buttonIcon, _buttonColor, _buttonStatus, event);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class TimerText extends StatelessWidget {
  final ValueListenable<String> time;
  final ValueListenable<Color> color;

  TimerText(this.time, this.color);

  @override
  Widget build(BuildContext context) {
    return Text(
      time.value,
      style: TextStyle(fontSize: 60, color: color.value),
    );
  }
}

class StartButton extends StatelessWidget {
  final TimatoTimer timer;
  final ValueNotifier<IconData> icon;
  final ValueListenable<Color> color;
  final ValueListenable<ButtonStatus> status;
  final AbstractEvent event;

  var started = false;

  StartButton(this.timer, this.icon, this.color, this.status, this.event);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        if (status.value == ButtonStatus.normal) {
          if (started) {
            timer.stop();
            started = false;
            icon.value = Icons.play_arrow;
          } else {
            timer.start();
            started = true;
            icon.value = Icons.pause;
          }
        } else if (status.value == ButtonStatus.next) {
          ++TimatoTimerWidget.usedTimerNum.value;
          ++event.usedTimerNum;
          updateEvent(event);
          timer.stop();
          timer.restore();
        } else if (status.value == ButtonStatus.end) {
          ++TimatoTimerWidget.usedTimerNum.value;
          ++event.usedTimerNum;
          updateEvent(event);
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

class ButtonIcon extends StatelessWidget {
  final ValueListenable<IconData> icon;

  ButtonIcon(this.icon);
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: icon,
      builder: (BuildContext context, IconData value, Widget child) {
        if (value == Icons.play_arrow || value == Icons.pause) {
          return Icon(
            value,
            color: ConstantHelper.tomatoColor,
          );
        }
        return Icon(value, color: Colors.white,);
      },
    );
  }
}

getTimerData() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return [
    pref.getInt('timerLength') ?? 25 * 60,
    pref.getInt('relaxLength') ?? 25 * 60
  ];
}