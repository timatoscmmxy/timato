import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/material/colors.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:date_format/date_format.dart' as ddlFormat;

import 'package:shared_preferences/shared_preferences.dart';

import 'package:timato/core/event.dart';
import 'package:timato/core/event_repository.dart';
import 'package:timato/core/tag_repository.dart';
import 'package:timato/ui/add_event.dart';
import 'package:timato/ui/basics.dart';
import 'package:timato/ui/main_list.dart';
import 'package:timato/ui/event_detail_page.dart';
import 'package:timato/ui/settings_widget.dart';
import 'package:timato/ui/stats_page.dart';
import 'package:timato/ui/timato_timer_widget.dart';

class TodayList extends StatefulWidget {
  _TodayListState _state;

  @override
  _TodayListState createState() {
    _state = new _TodayListState();
    return _state;
  }

  void refreshState() {
    print("got hererererererer");
    getTodayEventList().then((data) {
      print(_state);
      if (_state == null || !_state.mounted) return;
      _state.refreshState();
    });
  }
}

class _TodayListState extends State<TodayList> {
  @override
  void initState() {
    refreshState();
  }

  void refreshState() {
    getTodayEventList().then((data) {
      setState(() {
        todayEventList = data;
      });
    });
  }

  String name = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
          elevation: 0,
          iconTheme: new IconThemeData(color: ConstantHelper.tomatoColor),
          title: new Text(
              TimatoLocalization.instance.getTranslatedValue('today_page'),
              style: TextStyle(color: ConstantHelper.tomatoColor)),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.settings, color: ConstantHelper.tomatoColor),
                onPressed: () async {
                  SharedPreferences pref =
                      await SharedPreferences.getInstance();
                  var value = await Navigator.push(context,
                      MaterialPageRoute(builder: (_) {
                    return Settings(pref);
                  }));
                  if (value != null && value) {
                    setState(() {});
                  }
                })
          ],
          backgroundColor: Colors.white),
      body: new Container(
        decoration: new BoxDecoration(
          color: Colors.white,
        ),
        child: _todayList(),
      ),
      drawer: new SideBar('TodayList'),
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
                  icon: Icon(Icons.schedule, color: Colors.black38),
                  onPressed: () async{
                    SharedPreferences _prefs = await SharedPreferences.getInstance();
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_){
                        return TimatoTimerWidget(
                          timerLength: _prefs.getInt('timerLength'),
                          relaxLength: _prefs.getInt('relaxLength'),
                          event: Event(
                              taskName: TimatoLocalization.instance.getTranslatedValue('plain_pomodoro_timer'),
                              usedTimerNum: 0
                          ),
                        );
                      }
                    ));
                  },
                ),
                Expanded(child: Container()),
                IconButton(
                  icon: Icon(Icons.assessment, color: Colors.black38),
                  onPressed: () async {
                    var weekDayTimerNums = await getWeekTimerNum();
                    var timerNumsToday = await getTodayTimerNum();
                    var timerNumsWeek = weekDayTimerNums.fold(
                        0, (previousValue, element) => previousValue + element);
                    var tagTimerNumsToday = await getTodayTagTimerNum();
                    var tagTimerNumsWeek = await getWeekTagTimerNum();

                    Navigator.push(context, MaterialPageRoute(builder: (_) {
                      return StatsPage(
                        timerNumsWeek: timerNumsWeek,
                        tagTimerNumsToday: tagTimerNumsToday,
                        timerNumsToday: timerNumsToday,
                        tagTimerNumsWeek: tagTimerNumsWeek,
                        weekDayTimerNums: weekDayTimerNums,
                      );
                    }));
                  },
                ),
              ],
            )),
        elevation: 20,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          AddEvent.showAddEvent(1, context, (e) {
            getTodayEventList().then(
              (data) {
                setState(() {
                  todayEventList = data;
                });
              },
            );
          });
        },
        child: Icon(Icons.add, color: ConstantHelper.tomatoColor),
        backgroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _todayList() {
    return ReorderableListView(
      children: todayEventList.map(
        (task) {
          if (task.isUnplanned == 1) {
            return Container(
                key: task.key,
                height: 40,
                child: new Column(children: <Widget>[
                  Slidable(
                      actionPane: SlidableDrawerActionPane(),
                      actionExtentRatio: 0.25,
                      secondaryActions: <Widget>[
                        IconSlideAction(
                            color: ConstantHelper.tomatoColor,
                            iconWidget: IconButton(
                                icon: Icon(Icons.delete, color: Colors.white),
                                onPressed: () => {
                                      WarningDialog.show(
                                          title: TimatoLocalization.instance
                                              .getTranslatedValue(
                                                  'delete_unplanned_title'),
                                          text: TimatoLocalization.instance
                                              .getTranslatedValue(
                                                  'delete_unplanned'),
                                          context: context,
                                          action: (context) {
                                            deleteEvent(task.id).then((_) {
                                              refreshState();
                                            });
                                          })
                                    })),
                        IconSlideAction(
                            color: ConstantHelper.tomatoColor,
                            iconWidget: IconButton(
                              icon: Icon(Icons.play_circle_outline,
                                  color: Colors.white),
                              onPressed: () async {
                                List<int> timerData = await getTimerData();
                                int timerLength = timerData[0];
                                int relaxLength = timerData[1];
                                int currentClockNum = await task.clockNum;
                                var needRefresh = await Navigator.push(context,
                                    MaterialPageRoute(builder: (_) {
                                  return TimatoTimerWidget(
                                    timerLength: timerLength,
                                    relaxLength: relaxLength,
                                    event: task,
                                    clockNum: currentClockNum,
                                  );
                                }));
                                refreshState();
                              },
                            ))
                      ],
                      child: Container(
                          margin: EdgeInsets.all(5.0),
                          child: new Column(children: <Widget>[
                            new Row(
                              children: <Widget>[
                                SizedBox(width: 15),
                                Icon(Icons.warning,
                                    color: ConstantHelper.tomatoColor),
                                SizedBox(width: 8),
                                Container(
                                    width:
                                        MediaQuery.of(context).size.width - 100,
                                    child: Text(task.taskName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: false,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black87,
                                        )))
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                          ]))),
                  Divider(
                    color: Colors.grey[350],
                    height: 1,
                  ),
                ]));
          } else {
            return TaskTile(key: task.key, task: task);
          }
        },
      ).toList(),
      onReorder: _onReorder,
    );
  }

  ///[onreorder] uses in [ReorderableListView]
  void _onReorder(int oldIndex, int newIndex) {
    if (newIndex >= todayEventList.length) {
      todayEventList[oldIndex].todayOrder = todayEventList.last.todayOrder;
      updateEvent(todayEventList[oldIndex]);
      for (int i = oldIndex + 1; i < todayEventList.length; i++) {
        todayEventList[i].todayOrder -= 1;
        updateEvent(todayEventList[i]);
      }
    } else if (oldIndex < newIndex) {
      todayEventList[oldIndex].todayOrder = newIndex;
      updateEvent(todayEventList[oldIndex]);
      for (int i = oldIndex + 1; i <= newIndex; i++) {
        todayEventList[i].todayOrder -= 1;
        updateEvent(todayEventList[i]);
      }
    } else if (oldIndex > newIndex) {
      todayEventList[oldIndex].todayOrder = newIndex;
      updateEvent(todayEventList[oldIndex]);
      for (int i = newIndex; i < oldIndex; i++) {
        todayEventList[i].todayOrder += 1;
        updateEvent(todayEventList[i]);
      }
    }
    getTodayEventList().then((data) {
      setState(() {
        todayEventList = data;
      });
    });
  }
}

class TaskTile extends StatefulWidget {
  TaskTile({Key key, this.task}) : super(key: key);
  final Event task;
  @override
  TaskTileState createState() => TaskTileState(task);
}

class TaskTileState extends State<TaskTile> {
  TaskTileState(this.task);
  final Event task;
  List<Event> subtasksList = [];

  @override
  void initState() {
    _subtasksListHelper(task);
  }

  Future<void> _subtasksListHelper(Event task) async {
    subtasksList = await getSubevent(task);
    setState(() {});
  }

  Widget build(BuildContext context) {
    return Container(
        key: task.key,
        child: InkWell(
            onTap: () async {
              var needRefresh =
                  await Navigator.push(context, MaterialPageRoute(builder: (_) {
                return EventList(task: task, page: "todayList");
              }));
              if (needRefresh != null && needRefresh) {
                context
                    .findAncestorWidgetOfExactType<TodayList>()
                    .refreshState();
              }
            },
            child: new Column(children: <Widget>[
              Container(
                  width: MediaQuery.of(context).size.width,
                  color: Colors.white,
                  child: new Column(
                    children: <Widget>[
                      Slidable(
                          actionPane: SlidableDrawerActionPane(),
                          actionExtentRatio: 0.25,
                          secondaryActions: <Widget>[
                            IconSlideAction(
                                color: ConstantHelper.tomatoColor,
                                iconWidget: IconButton(
                                    icon:
                                        Icon(Icons.cancel, color: Colors.white),
                                    onPressed: () => {
                                          WarningDialog.show(
                                              title: TimatoLocalization.instance
                                                  .getTranslatedValue(
                                                      'remove_task_title'),
                                              text: TimatoLocalization.instance
                                                  .getTranslatedValue(
                                                      'remove_task'),
                                              context: context,
                                              action: (context) {
                                                task.isTodayList = 0;
                                                updateEvent(task).then((id) {
                                                  context
                                                      .findAncestorWidgetOfExactType<
                                                          TodayList>()
                                                      .refreshState();
                                                });
                                              })
                                        })),
                            IconSlideAction(
                                color: ConstantHelper.tomatoColor,
                                iconWidget: IconButton(
                                  icon: Icon(Icons.play_circle_outline,
                                      color: Colors.white),
                                  onPressed: () async {
                                    List<int> timerData = await getTimerData();
                                    int timerLength = timerData[0];
                                    int relaxLength = timerData[1];
                                    int currentClockNum = await task.clockNum;
                                    var needRefresh =
                                        await Navigator.push(context,
                                            MaterialPageRoute(builder: (_) {
                                      return TimatoTimerWidget(
                                        timerLength: timerLength,
                                        relaxLength: relaxLength,
                                        event: task,
                                        clockNum: currentClockNum,
                                      );
                                    }));
                                    context
                                        .findAncestorWidgetOfExactType<
                                            TodayList>()
                                        .refreshState();
                                  },
                                ))
                          ],
                          child: Container(
                              margin: EdgeInsets.all(3.0),
                              child: new Column(children: <Widget>[
                                new Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(top: 3.9),
                                        child: Container(
                                          height: 20,
                                          width: 20,
                                          decoration: BoxDecoration(
                                            color: ConstantHelper.priorityColor(
                                                task),
                                            border: new Border.all(
                                                color: Colors.black38,
                                                width: 0.5),
                                            borderRadius:
                                                new BorderRadius.circular(
                                                    (20.0)),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      new Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            new Row(children: <Widget>[
                                              ///Contains [taskName]
                                              Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width -
                                                      100,
                                                  margin: EdgeInsets.all(5.0),
                                                  child: Text(task.taskName,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      softWrap: false,
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.black87,
                                                      )))
                                            ]),

                                            ///Contains [tag] and [ddl]
                                            ConstantHelper.tagDdl(task),
                                          ]),
                                    ]),
                                _sublist(task),
                              ]))),
                      Divider(color: Colors.grey[350], height: 1)
                    ],
                  ))
            ])));
  }

  Widget _sublist(Event task) {
    if (subtasksList.length == 0) {
      return SizedBox(height: 5);
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 12,
          ),
          Container(
            padding: EdgeInsets.only(top: 5),
          ),
          Container(
              width: MediaQuery.of(context).size.width - 71,
              height: 30.0 * (subtasksList.length),
              child: ListView(
                primary: false,
                physics: const NeverScrollableScrollPhysics(),
                children: subtasksList.map((subtask) {
                  return Container(
                      key: subtask.key,
                      child: new Row(
                        children: <Widget>[
                          SizedBox(width: 30),
                          Icon(
                            Icons.fiber_manual_record,
                            color: Colors.red[100],
                            size: 10,
                          ),
                          SizedBox(width: 5),
                          Container(
                              height: 30,
                              child: new Column(children: <Widget>[
                                SizedBox(
                                  height: 6,
                                ),
                                Container(
                                    alignment: Alignment.centerLeft,
                                    width:
                                        MediaQuery.of(context).size.width - 125,
                                    child: Text(subtask.taskName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: false,
                                        style: TextStyle(fontSize: 15),
                                        textAlign: TextAlign.center))
                              ]))
                        ],
                      ));
                }).toList(),
              )),
        ],
      );
    }
  }
}