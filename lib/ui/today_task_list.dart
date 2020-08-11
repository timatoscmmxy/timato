import 'dart:developer' as developer;

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
import 'package:timato/ui/add_event.dart';
import 'package:timato/ui/basics.dart';
import 'package:timato/ui/main_list.dart';
import 'package:timato/ui/event_list.dart';
import 'package:timato/ui/settings_widget.dart';
import 'package:timato/ui/timato_timer_widget.dart';

class TodayList extends StatefulWidget {
  _TodayListState _state;

  @override
  _TodayListState createState() {
    _state = new _TodayListState();
    return _state;
  }

  void refreshState() {
    getTodayEventList().then((data) {
      if (_state == null || !_state.mounted) return;
      _state.setState(() {
        todayEventList = data;
      });
    });
  }
}

class _TodayListState extends State<TodayList> {
  @override
  void initState() {
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
            iconTheme: new IconThemeData(color: ConstantHelper.tomatoColor),
            title: new Text("Today's Tasks",
                style: TextStyle(color: ConstantHelper.tomatoColor)),
            actions: <Widget>[
              IconButton(
                  icon: Icon(Icons.settings, color: ConstantHelper.tomatoColor),
                  onPressed: () async {
                    SharedPreferences pref =
                        await SharedPreferences.getInstance();
                    Navigator.push(context, MaterialPageRoute(builder: (_) {
                      return Settings(pref);
                    }));
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
                Expanded(child: Container()),
              ],
            )),
        elevation: 20,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          AddEvent.showAddEvent(1,context, (e) {
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,);
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
                                          title: 'Delete this unplanned event?',
                                          text:
                                              'Are you sure to delete this unplanned event permanently?',
                                          context: context,
                                          action: (context) {
                                            deleteEvent(task.id);
                                            
                                              // context
                                              //     .findAncestorWidgetOfExactType<
                                              //         TodayList>()
                                              //     .refreshState();
                                              getTodayEventList().then((data) {
                                                setState(() {
                                                  todayEventList = data;
                                                });
                                              });
                                            // });
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
                                var needRefresh = await Navigator.pushReplacement(context,
                                    MaterialPageRoute(builder: (_) {
                                  return TimatoTimerWidget(
                                      timerLength: timerLength,
                                      relaxLength: relaxLength,
                                      event: task,
                                      clockNum: currentClockNum);
                                }));

                                if (needRefresh != null && needRefresh) {
                                  getTodayEventList().then((data) {
                                    setState(() {
                                      todayEventList = data;
                                    });
                                  });
                                }
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
                                SizedBox(width: 5),
                                Text(task.taskName,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ))
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
    //
    return Container(
        key: task.key,
        child: InkWell(
            onTap: () async {
              var needRefresh =
                  await Navigator.push(context, MaterialPageRoute(builder: (_) {
                return EventList(task: task, page: "todayList");
              }));
              // developer.log(needRefresh);
              if (needRefresh != null && needRefresh) {
                // developer.log(needRefresh);
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
                                    icon: Icon(Icons.delete_sweep,
                                        color: Colors.white),
                                    onPressed: () => {
                                          WarningDialog.show(
                                              title: 'Remove this task?',
                                              text:
                                                  "Are you sure to remove this task from Today's Tasks?",
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
                                    // task.duration =
                                    // int.parse(unplannedDuration);
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
                                          clockNum: currentClockNum);
                                    }));

                                    if (needRefresh != null && needRefresh) {
                                      context
                                          .findAncestorWidgetOfExactType<
                                              TodayList>()
                                          .refreshState();
                                    }
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
                                        width: 10,
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
                                                  margin: EdgeInsets.all(5.0),
                                                  child: Text(task.taskName,
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.black87,
                                                        //fontWeight: FontWeight.bold
                                                      )))
                                            ]),

                                            ///Contains [tag] and [ddl]

                                            ConstantHelper.tagDdl(task),
                                          ]),
                                    ]),
                                _sublist(task),
                                // SizedBox(height: 4),
                                // Divider(color: Colors.grey[350],height:1)
                              ]))),
                      Divider(color: Colors.grey[350], height: 1)
                    ],
                  ))
            ])));

    // );
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
            child: Icon(Icons.subject,
                size: 20, color: ConstantHelper.tomatoColor),
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
                          SizedBox(width: 15),
                          Container(
                              height: 30,
                              child: new Column(children: <Widget>[
                                SizedBox(
                                  height: 6,
                                ),
                                Text(subtask.taskName,
                                    style: TextStyle(fontSize: 16),
                                    textAlign: TextAlign.center)
                              ]))
                        ],
                      ));
                }).toList(),
              )),
        ],
      );
    }
  }

  // Widget tagDdl(Event task) {
  //   if (task.tag == null && task.ddl == null) {
  //     return SizedBox();
  //   } else {
  //     return new Row(
  //       children: <Widget>[
  //         SizedBox(width: 5),
  //         _tag(task),
  //         SizedBox(
  //           width: 5,
  //           height: 1,
  //         ),
  //         _ddl(task)
  //       ],
  //     );
  //   }
  // }

  // Widget _tag(Event task) {
  //   if (task.tag != null) {
  //     return Container(
  //       child: Text(task.tag,
  //           style: TextStyle(color: Colors.black87, fontSize: 12)),
  //       decoration: BoxDecoration(
  //         shape: BoxShape.rectangle,
  //         borderRadius: BorderRadius.circular(10),
  //         color: Colors.white,
  //       ),
  //       padding: EdgeInsets.all(2),
  //     );
  //   } else {
  //     return SizedBox(
  //       width: 0.1,
  //     );
  //   }
  // }

  // Widget _ddl(Event task) {
  //   if (task.ddl != null) {
  //     String formatDdl = ddlFormat.formatDate(
  //         task.ddl, [ddlFormat.yyyy, '-', ddlFormat.mm, '-', ddlFormat.dd]);
  //     return Container(
  //       child: Text(formatDdl,
  //           style: TextStyle(color: Colors.black87, fontSize: 12)),
  //       decoration: BoxDecoration(
  //         shape: BoxShape.rectangle,
  //         borderRadius: BorderRadius.circular(10),
  //         color: Colors.white,
  //       ),
  //       padding: EdgeInsets.all(2),
  //     );
  //   } else {
  //     return SizedBox(width: 0.1);
  //   }
  // }
}
