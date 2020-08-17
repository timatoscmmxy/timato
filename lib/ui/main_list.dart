import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:timato/core/event.dart';
import 'package:timato/core/event_repository.dart';
import 'package:timato/ui/add_event.dart';
import 'package:timato/ui/basics.dart';
import 'package:timato/ui/event_detail_page.dart';

class MyTask extends StatefulWidget {
  _MyTaskState _state;
  @override
  _MyTaskState createState() {
    _state = new _MyTaskState();
    return _state;
  }

  void refreshState() {
    getEventList().then((data) {
      if (_state == null || !_state.mounted) return;
      _state.setState(() {
        eventsList = data;
      });
    });
  }
}

class _MyTaskState extends State<MyTask> {
  @override
  void initState() {
    getTodayEventList().then((data) {
      setState(() {
        todayEventList = data;
      });
    });
    getEventList().then((data) {
      setState(() {
        eventsList = data;
      });
    });
  }

  String name = "";
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return new Scaffold(
      appBar: new AppBar(
          elevation: 0,
          iconTheme: new IconThemeData(color: ConstantHelper.tomatoColor),
          title: new Text("My Tasks",
              style: TextStyle(color: ConstantHelper.tomatoColor)),
          backgroundColor: Colors.white),
      body: Container(
          decoration: new BoxDecoration(
            color: Colors.white,
          ),
          child: _list()),
      drawer: new SideBar('MyTask'),
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
          AddEvent.showAddEvent(0, context, (e) {
            getEventList().then(
              (data) {
                setState(() {
                  eventsList = data;
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

  Widget _list() {
    return ReorderableListView(
      children: eventsList.map((task) {
        if (task.isUnplanned == 1) {
          return Container(
              color: Colors.white,
              key: task.key,
              height: 40,
              child: Slidable(
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
                                        getTodayEventList().then((data) {
                                          setState(() {
                                            todayEventList = data;
                                          });
                                        });
                                      })
                                })),
                  ],
                  child: Container(
                      margin: EdgeInsets.all(5.0),
                      child: new Row(
                        children: <Widget>[
                          SizedBox(width: 15),
                          Icon(Icons.warning,
                              color: ConstantHelper.tomatoColor),
                          SizedBox(width: 5),
                          Text(task.taskName,
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.black87,
                              ))
                        ],
                      ))));
        } else {
          return Slidable(
              key: task.key,
              actionPane: SlidableDrawerActionPane(),
              actionExtentRatio: 0.25,
              secondaryActions: <Widget>[
                IconSlideAction(
                    color: ConstantHelper.tomatoColor,
                    iconWidget: IconButton(
                        icon: Icon(Icons.add, color: Colors.white),
                        onPressed: () {
                          if (task.isTodayList == 1) {
                            Fluttertoast.showToast(
                                msg: "This task is on Today's Tasks already",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                backgroundColor: Colors.white,
                                textColor: ConstantHelper.tomatoColor,
                                fontSize: 16);
                          } else {
                            var data = WarningDialog.show(
                                title: "Add to today's tasks?",
                                text:
                                    "Are you sure to add this task to today's tasks?",
                                context: context,
                                action: (context) {
                                  getTodayEventList().then(
                                    (data) {
                                      setState(() {
                                        todayEventList = data;
                                      });
                                    },
                                  );
                                  if (todayEventList.length == 0) {
                                    task.todayOrder = 0;
                                  } else {
                                    task.todayOrder =
                                        todayEventList.last.todayOrder + 1;
                                  }
                                  task.isTodayList = 1;
                                  updateEvent(task);
                                  getTodayEventList().then(
                                    (data) {
                                      setState(() {
                                        todayEventList = data;
                                      });
                                    },
                                  );
                                  getEventList().then(
                                    (data) {
                                      setState(() {
                                        eventsList = data;
                                      });
                                    },
                                  );
                                  Fluttertoast.showToast(
                                      msg: "Added",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      backgroundColor: Colors.white,
                                      textColor: ConstantHelper.tomatoColor,
                                      fontSize: 16);
                                });
                          }
                        })),
                IconSlideAction(
                    color: ConstantHelper.tomatoColor,
                    iconWidget: IconButton(
                      icon: Icon(Icons.delete, color: Colors.white),
                      onPressed: () => {
                        WarningDialog.show(
                            title: 'Delete this task?',
                            text: 'Are you sure to delete this task?',
                            context: context,
                            action: (context) {
                              deleteEvent(task.id);
                              getEventList().then((data) {
                                setState(() {
                                  eventsList = data;
                                });
                              });
                            })
                      },
                    )),
                IconSlideAction(
                    color: ConstantHelper.tomatoColor,
                    iconWidget: IconButton(
                      icon: Icon(Icons.receipt, color: Colors.white),
                      onPressed: () async {
                        var needRefresh = await Navigator.push(context,
                            MaterialPageRoute(builder: (_) {
                          return EventList(task: task, page: "mainList");
                        }));
                        if (needRefresh != null && needRefresh) {
                          getSubevent(task).then((data) {
                            subtasksList = data;
                          });
                          getEventList().then((data) {
                            setState(() {
                              eventsList = data;
                            });
                          });
                        }
                      },
                    ))
              ],
              child: ListExpan(task: task));
        }
      }).toList(),
      onReorder: _onReorder,
    );
  }

  ///[onreorder] uses in [ReorderableListView]
  void _onReorder(int oldIndex, int newIndex) {
    if (newIndex >= eventsList.length) {
      eventsList[oldIndex].taskOrder = eventsList.last.taskOrder;
      updateEvent(eventsList[oldIndex]);
      for (int i = oldIndex + 1; i < eventsList.length; i++) {
        eventsList[i].taskOrder -= 1;
        updateEvent(eventsList[i]);
      }
    } else if (oldIndex < newIndex) {
      eventsList[oldIndex].taskOrder = newIndex;
      updateEvent(eventsList[oldIndex]);
      for (int i = oldIndex + 1; i <= newIndex; i++) {
        eventsList[i].taskOrder -= 1;
        updateEvent(eventsList[i]);
      }
    } else if (oldIndex > newIndex) {
      eventsList[oldIndex].taskOrder = newIndex;
      updateEvent(eventsList[oldIndex]);
      for (int i = newIndex; i < oldIndex; i++) {
        eventsList[i].taskOrder += 1;
        updateEvent(eventsList[i]);
      }
    }
    getEventList().then((data) {
      setState(() {
        eventsList = data;
      });
    });
  }
}

class ListExpan extends StatefulWidget {
  ListExpan({Key key, this.task}) : super(key: key);

  final Event task;
  @override
  _ListExpanState createState() => _ListExpanState(task: task);
}

class _ListExpanState extends State<ListExpan> {
  _ListExpanState({this.task});

  final Event task;

  List<Event> subtasksList = [];

  @override
  void initState() {
    _subtasksListHelper(task);
  }

  void _subtasksListHelper(Event task) async {
    subtasksList = await getSubevent(task);
    if (this.mounted) setState(() {});
  }

  void _getSub(Event task) async {
    subtasksList = await getSubevent(task);
  }

  double _height(Event task) {
    if (this.task.tag == null && this.task.ddl == null) {
      return 40;
    } else {
      return 55;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildTiles(task);
  }

  Widget _buildTiles(Event task) {
    print(subtasksList);
    if (subtasksList.isEmpty) {
      return new Row(children: <Widget>[
        SizedBox(width: 16),
        _event(task),
      ]);
    } else {
      return Container(
          color: Colors.white,
          child: ExpansionTile(
            title: _event(task),
            onExpansionChanged: (value) {},
            children: <Widget>[
              Container(
                  height: (40.0 * subtasksList.length),
                  child: ListView(
                      primary: false,
                      physics: new NeverScrollableScrollPhysics(),
                      children: subtasksList.map((subtask) {
                        return Slidable(
                            key: subtask.key,
                            actionPane: SlidableDrawerActionPane(),
                            actionExtentRatio: 0.25,
                            secondaryActions: <Widget>[
                              IconSlideAction(
                                  color: ConstantHelper.tomatoColor,
                                  iconWidget: IconButton(
                                    icon:
                                        Icon(Icons.delete, color: Colors.white),
                                    onPressed: () => {
                                      WarningDialog.show(
                                          title: 'Delete this subtask?',
                                          text:
                                              'Are you sure to delete this subtask?',
                                          context: context,
                                          action: (context) {
                                            deleteEvent(subtask.id);
                                            getSubevent(task).then((data) {
                                              if (this.mounted) {
                                                setState(() {
                                                  subtasksList = data;
                                                });
                                              }
                                            });
                                          })
                                    },
                                  ))
                            ],
                            child: _subevent(subtask));
                      }).toList()))
            ],
          ));
    }
  }

  Widget _event(Event task) {
    return Container(
      key: task.key,
      margin: EdgeInsets.all(5.0),
      height: _height(task),
      color: Colors.white,
      child: new Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: 3.9),
              child: Container(
                height: 20,
                width: 20,
                decoration: BoxDecoration(
                  color: ConstantHelper.priorityColor(task),
                  border: new Border.all(color: Colors.black38, width: 0.5),
                  borderRadius: new BorderRadius.circular((20.0)),
                ),
              ),
            ),
            SizedBox(width: 3),
            new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Row(children: <Widget>[
                    ///Contains [taskName]
                    Container(
                        margin: EdgeInsets.all(5.0),
                        child: Text(task.taskName,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 17,
                              color: Colors.black87,
                            )))
                  ]),

                  ///Contains [tag] and [ddl]
                  ConstantHelper.tagDdl(task)
                ]),
          ]),
    );
  }

  ///Build each [Subevent] on subevent's list
  Widget _subevent(Event subtask) {
    return Container(
      height: 40,
      color: Colors.white70,
      child: new Row(children: <Widget>[
        SizedBox(
          width: 30,
          height: 1,
        ),

        ///Contains [subtaskName]
        Icon(
          Icons.fiber_manual_record,
          color: Colors.red[100],
          size: 10,
        ),
        Container(
            margin: EdgeInsets.all(5.0),
            child: Text(subtask.taskName,
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 16, color: Colors.black87)))
      ]),
    );
  }
}