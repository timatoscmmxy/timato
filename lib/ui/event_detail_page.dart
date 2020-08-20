// import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:date_format/date_format.dart' as ddlFormat;
import 'package:fluttertoast/fluttertoast.dart';

import 'package:timato/core/event.dart';
import 'package:timato/core/event_repository.dart';
import 'package:timato/ui/add_event.dart';
import 'package:timato/ui/basics.dart';
import 'package:timato/core/db.dart';
import 'package:timato/ui/timato_timer_widget.dart';
import 'package:timato/ui/main_list.dart';
import 'package:timato/core/repeat_properties.dart';
import 'package:timato/ui/today_task_list.dart';

List<Event> subtasksList = [];

class EventList extends StatefulWidget {
  EventList({Key key, this.task, this.page}) : super(key: key);
  final Event task;
  final String page;

  @override
  _EventListState createState() => _EventListState(task: task, page: page);
}

class _EventListState extends State<EventList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  _EventListState({this.task, this.page});
  final Event task;
  final String page;

  @override
  void initState() {
    super.initState();
    getSubevent(task).then((data) {
      setState(() {
        subtasksList = data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    bool keyboardIsOpened = MediaQuery.of(context).viewInsets.bottom != 0.0;
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: ConstantHelper.tomatoColor),
              onPressed: () {
                if (this.task.taskName == '') {
                  Fluttertoast.showToast(
                      msg: TimatoLocalization.instance
                          .getTranslatedValue('task_name_empty'),
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      backgroundColor: Colors.white,
                      textColor: ConstantHelper.tomatoColor,
                      fontSize: 16);
                } else {
                  Navigator.pop(context, true);
                }
              }),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.delete, color: ConstantHelper.tomatoColor),
              onPressed: () => {
                WarningDialog.show(
                    title: TimatoLocalization.instance
                        .getTranslatedValue('delete_task_title'),
                    text: TimatoLocalization.instance
                        .getTranslatedValue('delete_task'),
                    context: context,
                    action: (context) {
                      deleteEvent(task.id);
                      getEventList().then((data) {
                        setState(() {
                          eventsList = data;
                        });
                      });
                      getTodayEventList().then((data) {
                        setState(() {
                          todayEventList = data;
                        });
                      });
                      Navigator.pop(context, true);
                    })
              },
            ),
          ]),
      body: _eventDetail(task),
      floatingActionButton: keyboardIsOpened ? null : _button(page),
    );
  }

  void changePage(String page) {
    if (page == 'mainList') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) {
        return MyTask();
      }));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) {
        return TodayList();
      }));
    }
  }

  FloatingRaisedButton _button(String page) {
    if (page == 'mainList') {
      return FloatingRaisedButton(
          TimatoLocalization.instance.getTranslatedValue('done'), () async {
        if (this.task.taskName == '') {
          Fluttertoast.showToast(
              msg: TimatoLocalization.instance
                  .getTranslatedValue('task_name_empty'),
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              backgroundColor: Colors.white,
              textColor: ConstantHelper.tomatoColor,
              fontSize: 16);
        } else {
          updateEvent(task);
          Navigator.pop(context, true);
        }
      });
    } else {
      return FloatingRaisedButton(
          TimatoLocalization.instance.getTranslatedValue('start_clock'),
          () async {
        List<int> timerData = await getTimerData();
        int timerLength = timerData[0];
        int relaxLength = timerData[1];
        int currentClockNum = await task.clockNum;
        var needRefresh =
            await Navigator.push(context, MaterialPageRoute(builder: (_) {
          return TimatoTimerWidget(
            timerLength: timerLength,
            relaxLength: relaxLength,
            event: task,
            clockNum: currentClockNum,
          );
        }));
        if (needRefresh != null && needRefresh) {
          getTodayEventList().then((data) {
            todayEventList = data;
          });
          Navigator.pop(context, true);
        }
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
    SizedBox(height: 12),
    TextName(task: task),
    TaskTag(task: task),
    TaskDate(task: task),
    TaskPriority(task: task),
    SizedBox(height: 10),
    TaskDuration(task: task),
    RepeatTime(task: task),
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
        // width:200,
        child: TextFormField(
      style: TextStyle(fontSize: 17),
      onChanged: (text) {
        this.task.taskName = text;
        updateEvent(task);
        print('$this.task.taskName');
      },
      textInputAction: TextInputAction.done,
      maxLength: 100,
      maxLines: 3,
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
      Container(
          width: MediaQuery.of(context).size.width - 50,
          child: TextFormField(
            onChanged: (text) {
              if (text != '') {
                this.task.tag = text;
                updateEvent(task);
                print('$this.task.tag');
              }
            },
            textInputAction: TextInputAction.done,
            maxLength: 50,
            initialValue: this.task.tag,
            style: TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText:
                  TimatoLocalization.instance.getTranslatedValue('give_tag'),
              counterText: '',
              border: InputBorder.none,
              prefix: Text('   '),
            ),
          ))
    ]));
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
        locale: TimatoLocalization.instance.locale,
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2200));
    if (picked != null && picked != this.task.ddl)
      setState(() {
        this.task.ddl = picked;
        updateEvent(task);
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
          return TimatoLocalization.instance.getTranslatedValue('select_date');
        }
      })(), style: TextStyle(color: Colors.black54)),
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
        SizedBox(width: 13),
        Container(
          height: 20,
          width: 20,
          decoration: BoxDecoration(
            color: ConstantHelper.priorityColor(task),
            border: new Border.all(color: Colors.black38, width: 0.5),
            borderRadius: new BorderRadius.circular((20.0)),
          ),
        ),
        SizedBox(width: 12),
        DropdownButton<String>(
          value: ConstantHelper.priorityString[this.task.eventPriority],
          onChanged: (String priority) {
            setState(() {
              Priority value = ConstantHelper.priorityEnum[priority];
              this.task.eventPriority = value;
              updateEvent(task);
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

  String _duration(Event task) {
    if (task.duration != null && task.duration != '') {
      return task.duration.toString();
    }
  }

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
            textInputAction: TextInputAction.done,
            inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
            maxLength: 4,
            initialValue: _duration(task),
            decoration: InputDecoration(
                hintText: TimatoLocalization.instance
                    .getTranslatedValue('it_might_take'),
                suffixText:
                    TimatoLocalization.instance.getTranslatedValue('minutes'),
                counterText: '',
                border: InputBorder.none),
            onChanged: (String text) {
              if (text == '') {
                task.duration = null;
                updateEvent(task);
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
              updateEvent(this.task);
              print('$this.task.duration');
            },
          ))
    ]));
  }
}

class RepeatTime extends StatefulWidget {
  RepeatTime({Key key, this.task}) : super(key: key);
  final Event task;

  @override
  _RepeatTimeState createState() => _RepeatTimeState(task);
}

class _RepeatTimeState extends State<RepeatTime> {
  _RepeatTimeState(this.task);
  final Event task;

  Widget _repeatProperties(Event task) {
    if (task.repeatProperties == null) {
      return Text(
          TimatoLocalization.instance.getTranslatedValue('repeat_property'),
          style: TextStyle(color: Colors.black54));
    } else {
      return Text(
          TimatoLocalization.instance.getTranslatedValue('next_occurrence') +
              ddlFormat.formatDate(
                  task.repeatProperties.nextOccurrence().toDateTimeLocal(),
                  [ddlFormat.yyyy, '-', ddlFormat.mm, '-', ddlFormat.dd]));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: new Row(
      children: <Widget>[
        IconButton(
            icon: Icon(Icons.repeat, color: ConstantHelper.tomatoColor),
            onPressed: () async {
              RepeatProeprties repeatPrrperties =
                  await SetRepeatProperties.show(
                      context, task.ddl ?? dateOnly(DateTime.now()));
              task.repeatProperties = repeatPrrperties;
              updateEvent(this.task);
              if (repeatPrrperties != null) {
                setState(() {});
              }
            }),
        _repeatProperties(task)
      ],
    ));
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
  _SubtaskListState createState() => _SubtaskListState(task: task);
}

class _SubtaskListState extends State<SubtaskList> {
  _SubtaskListState({this.task});
  final Event task;

  int _subLength(List<Event> subtasksList) {
    int subLength;
    if (subtasksList == []) {
      subLength = 0;
    } else {
      subLength = subtasksList.length;
    }
    return subLength;
  }

  @override
  void initState() {
    getSubevent(task).then((data) {
      setState(() {
        subtasksList = data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
        height: 35.0 * (_subLength(subtasksList) + 2) + 20 + 22,
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
                height: 35.0 * (_subLength(subtasksList) + 2) + 20 + 22,
                child: _sublist(task)),
          ],
        ));
  }

  Widget _sublist(Event task) {
    return Column(children: <Widget>[
      SizedBox(height: 22),
      Container(
          height: 35.0 * (_subLength(subtasksList)),
          child: ListView(
            physics: NeverScrollableScrollPhysics(),
            children: subtasksList.map((subtask) {
              return Slidable(
                  key: subtask.key,
                  actionPane: SlidableDrawerActionPane(),
                  actionExtentRatio: 0.25,
                  secondaryActions: <Widget>[
                    IconSlideAction(
                        color: ConstantHelper.tomatoColor,
                        iconWidget: IconButton(
                          icon: Icon(Icons.delete, color: Colors.white),
                          onPressed: () => {
                            deleteEvent(subtask.id),
                            getSubevent(task).then((data) {
                              setState(() {
                                subtasksList = data;
                              });
                            })
                          },
                        ))
                  ],
                  child: SublistDetail(subtask: subtask));
            }).toList(),
          )),
      Container(
        height: 70,
        child: TextField(
            maxLines: 3,
            controller: TextEditingController()..text = '',
            onChanged: (text) => {},
            onSubmitted: (text) {
              if (text.length != 0) {
                Event sub = new Event(taskName: text);
                sub.whichTask = task.id;
                insertEvent(sub);
                getSubevent(task).then((data) {
                  setState(() {
                    subtasksList = data;
                  });
                });
              }
            },
            textInputAction: TextInputAction.done,
            maxLength: 50,
            decoration: InputDecoration(
                counterText: '',
                border: InputBorder.none,
                prefix: Text('   '),
                hintText: TimatoLocalization.instance
                    .getTranslatedValue('add_subtask'))),
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
  final Event subtask;
  @override
  _SublistDetailState createState() => _SublistDetailState(subtask);
}

class _SublistDetailState extends State<SublistDetail> {
  _SublistDetailState(this.subtask);
  final Event subtask;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        child: Row(
          children: <Widget>[
            Container(
                width: MediaQuery.of(context).size.width - 75,
                child: TextFormField(
                  onChanged: (text) {
                    subtask.taskName = text;
                    updateEvent(subtask);
                    print('$subtask.taskName');
                  },
                  textInputAction: TextInputAction.done,
                  maxLength: 50,
                  maxLines: 1,
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