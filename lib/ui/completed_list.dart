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

class CompletedList extends StatefulWidget {
  @override
  _CompletedListState createState() => _CompletedListState();
}

class _CompletedListState extends State<CompletedList> {
  DatabaseHelper tabaseHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
          iconTheme: new IconThemeData(color: ConstantHelper.tomatoColor),
          title: new Text("Completed Tasks",
              style: TextStyle(color: ConstantHelper.tomatoColor)),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.delete, color: ConstantHelper.tomatoColor),
                onPressed: () async {
                  var data=WarningDialog.show(
                      title: 'Empty completed list?',
                      text: 'Are you sure to empty all the completed tasks?',
                      context: context,
                      action: (context) {
                        deleteAllCompleted();
                        setState(() {
                          completed.clear();
                        });
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
      return new DateTile(date:title[i]);
    },
  );

  // children: <Widget>[
  //   //TODO: overflowed by 8px when height was 50
  //   Container(
  //       height: 58,
  //       color: Colors.white, child: DateTile(date: "Today")),
  //   Container(
  //       height: 58,
  //       color: Colors.white, child: DateTile(date: "Yesterday")),
  //   Container(
  //       height: 58,
  //       color: Colors.white,
  //       child: DateTile(date: "Before Yesterday")),
  // ],
  // );
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

  int findLength(List<Event> completed){
    if(completed == null){
      return 0;
    }else{
      return completed.length;
    }
  }

  Future<void> findCompleted(String date) async {
    // List<Event> completed=[];
    if (date == "Today") {
      completed = await getTodayCompletedList();
      //TODO:
      // completed = [];
      // getTodayCompletedList().then(
      //   (data) {
      //     // setState(() {
      //     completed = data;
      //     developer.log('right here2' + completed.toString());
      //     // return completed;
      //     // });
      //   },
      // );
    } else if (date == "Yesterday") {
      //TODO:
      completed=await getYesterdayCompletedList();
      // completed = [];
      // getYesterdayCompletedList().then(
      //   (data) {
      //     // int count = data.length;
      //     // for(int i=0;i<count;i++){
      //     //   completed.add(data[i]);
      //     // }
      //     // developer.log('right here2' + completed.toString());
      //     // setState(() {
      //     completed = data;
      //     developer.log('right here3' + completed.toString());
      //     // return completed;
      //     // });
      //   },
      // );
    } else {
      //TODO:
      // completed = [];

      completed=await getBeforeYesterdayCompletedList();

      // getBeforeYesterdayCompletedList().then(
      //   (data) {
      //     // setState(() {
      //     completed = data;
      //     // return completed;
      //     // developer.log('right here2'+completed.toString());
      //     // });
      //   },
      // );
    }
    //developer.log('right here4' + completed.toString());
    // return completed;
  }

  @override
  Widget build(BuildContext context) {
    findCompleted(date);
    // if (date == "Today") {
    //   //TODO:
    //   // completed = [];
    //   getTodayCompletedList().then(
    //     (data) {
    //       // setState(() {
    //         completed = data;
    //       // });
    //     },
    //   );
    // } else if (date == "Yesterday") {
    //   //TODO:
    //   // completed = [];
    //   getYesterdayCompletedList().then(
    //     (data) {
    //       // setState(() {
    //         completed = data;
    //       // });
    //     },
    //   );
    // } else {
    //   //TODO:
    //   // completed = [];
    //   getBeforeYesterdayCompletedList().then(
    //     (data) {
    //       // setState(() {
    //         completed = data;
    //       // });
    //     },
    //   );
    // }
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
                    var data=WarningDialog.show(
                        title: "Empty today's completed list?",
                        text:
                            "Are you sure to empty all the tasks you completed today?",
                        context: context,
                        action: (context) {
                          deleteToday();
                          setState(() {});
                        });
                  } else if (date == "Yesterday") {
                    var data=WarningDialog.show(
                        title: "Empty yesterday's completed list?",
                        text:
                            "Are you sure to empty all the tasks you completed yesterday?",
                        context: context,
                        action: (context) {
                          deleteYesterday();
                          setState(() {});
                        });
                  } else {
                    var data=WarningDialog.show(
                        title: "Empty otherdays' completed list?",
                        text:
                            "Are you sure to empty all the tasks you completed other days?",
                        context: context,
                        action: (context) {
                          deleteBeforeYesterday();
                          setState(() {});
                        });
                  }
                  setState(() {
                    completed.clear();
                  });
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
