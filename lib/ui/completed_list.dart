import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:timato/core/completed_repository.dart';
import 'package:timato/core/db.dart';
import 'package:timato/core/event.dart';
import 'package:timato/core/event_repository.dart';
import 'package:timato/ui/add_event.dart';
import 'package:timato/ui/basics.dart';

import 'dart:developer' as developer;

List<String> title = ['Today', 'Yesterday', 'Before Yesterday'];
// List<Event> completed=[];
Map<Key, Function> refreshFunc = Map<Key, Function>();

class CompletedList extends StatefulWidget {
  _CompletedListState _state;
  @override
  _CompletedListState createState() {
    _state = new _CompletedListState();
    return _state;
  }

  void refreshState() {
    if (_state == null || !_state.mounted) return;
    _state.setState(() {});
  }
}

class _CompletedListState extends State<CompletedList> {
  DatabaseHelper tabaseHelper = DatabaseHelper();

  @override
  void setState(VoidCallback fn) {
    if (this == null || !mounted) return;
    refreshFunc.forEach((key, value) {
      value();
    });

    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
          elevation: 0,
          iconTheme: new IconThemeData(color: ConstantHelper.tomatoColor),
          title: new Text("Completed Tasks",
              style: TextStyle(color: ConstantHelper.tomatoColor)),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.delete, color: ConstantHelper.tomatoColor),
                onPressed: () async {
                  var data = WarningDialog.show(
                      title: 'Empty completed list?',
                      text: 'Are you sure to empty all the completed tasks?',
                      context: context,
                      action: (context) async {
                        await deleteAllCompleted();
                        // _completed();
                        setState(() {});
                      });
                })
          ],
          backgroundColor: Colors.white),
      body: Container(
          decoration: new BoxDecoration(
            color: Colors.white,
          ),
          child: _completed()),
      drawer: new SideBar('Completed'),
    );
  }
}

Widget _completed() {
  return ListView.builder(
    itemCount: 3,
    itemBuilder: (BuildContext context, int i) {
      return new DateTile(date: title[i]);
    },
  );
}

class DateTile extends StatefulWidget {
  DateTile({Key key, this.date}) : super(key: key);
  final String date;
  @override
  _DateTileState createState() => _DateTileState(date);
}

class _DateTileState extends State<DateTile> {
  _DateTileState(this.date);
  final String date;
  List<Event> completed = [];
  Key _key = UniqueKey();

  int findLength(List<Event> completed) {
    if (completed == null) {
      return 0;
    } else {
      developer.log("what is the length" + completed.length.toString());
      return completed.length;
    }
  }

  @override
  void initState() {
    developer.log("initState");
    refreshFunc[_key] = this.refreshState;
    refreshState();
  }

  @override
  void dispose() {
    super.dispose();
    refreshFunc.remove(this._key);
  }

  void refreshState() {
    // developer.log(date);
    findCompleted(date);
  }

  Future<void> findCompleted(String date) async {
    // List<Event> completed=[];
    if (date == "Today") {
      completed = await getTodayCompletedList();
    } else if (date == "Yesterday") {
      completed = await getYesterdayCompletedList();
    } else {
      completed = await getBeforeYesterdayCompletedList();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // findCompleted(date);
    return Slidable(
        // key: task.key,
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        secondaryActions: <Widget>[
          IconSlideAction(
              color: ConstantHelper.tomatoColor,
              iconWidget: IconButton(
                icon: Icon(Icons.delete, color: Colors.white),
                onPressed: () async {
                  if (date == "Today") {
                    WarningDialog.show(
                        title: "Empty today's completed list?",
                        text:
                            "Are you sure to empty all the tasks you completed today?",
                        context: context,
                        action: (context) async {
                          await deleteToday();
                          // getTodayCompletedList().then((todayList) {
                          //   completed = todayList;
                          //   context
                          //       .findAncestorWidgetOfExactType<CompletedList>()
                          //       .refreshState();
                          // });
                          context
                              .findAncestorWidgetOfExactType<CompletedList>()
                              .refreshState();
                        });
                  } else if (date == "Yesterday") {
                    var data = WarningDialog.show(
                        title: "Empty yesterday's completed list?",
                        text:
                            "Are you sure to empty all the tasks you completed yesterday?",
                        context: context,
                        action: (context) async {
                          await deleteYesterday();
                          // getYesterdayCompletedList().then((yesterdayList) {
                          //   completed = yesterdayList;
                          context
                              .findAncestorWidgetOfExactType<CompletedList>()
                              .refreshState();
                          // });
                        });
                  } else {
                    var data = WarningDialog.show(
                        title: "Empty otherdays' completed list?",
                        text:
                            "Are you sure to empty all the tasks you completed other days?",
                        context: context,
                        action: (context) async {
                          await deleteBeforeYesterday();
                          // getBeforeYesterdayCompletedList()
                          //     .then((beforeYesterdayList) {
                          //   completed = beforeYesterdayList;
                          context
                              .findAncestorWidgetOfExactType<CompletedList>()
                              .refreshState();
                          // });
                        });
                  }
                  // setState(() {
                  //   completed.clear();
                  // });
                },
              )),
        ],
        child: ExpansionTile(
          title: Container(
              // height: 40,
              child: new Row(children: <Widget>[
            SizedBox(width: 12),
            // IconButton(icon: Icon(Icons.delete,color: ConstantHelper.tomatoColor,), onPressed: null),
            Text(date,
                style: TextStyle(
                    fontSize: 15,
                    color: ConstantHelper.tomatoColor,
                    fontWeight: FontWeight.bold))
          ])),
          onExpansionChanged: (value) {
            // developer.log("onExpansionChanged");
          },
          // developer.log(completed.toString());
          children: <Widget>[
            Container(
                // height: (35.0 * 2),
                height: (35.0 * findLength(completed)),
                child: ListView(
                    // key:task
                    physics: new NeverScrollableScrollPhysics(),
                    children: completed.map((completedTask) {
                      return Container(
                          height: 35,
                          child: new Row(children: <Widget>[
                            SizedBox(width: 30),
                            // Icon(Icons.brightness_1,
                            //     color: ConstantHelper.priorityColor(
                            //         completedTask)),
                            Text(completedTask.taskName,
                                style: TextStyle(fontSize: 14))
                          ]));
                      // _completedTask(completedTask);
                    }).toList()))
          ],
        ));
  }

  // Widget _completedTask(Event completedTask) {
  //   developer.log('!!!' + completed.toString());
  //   return Container(
  //       height: 50,
  //       child:
  //       // new Row(children: <Widget>[
  //         // SizedBox(width: 15),
  //         Text(completedTask.taskName, style: TextStyle(fontSize: 12))
  //       // ]
  //       );
  //       // );
  // }
}
