import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:date_format/date_format.dart' as ddlFormat;

import 'package:timato/core/event.dart';
import 'package:timato/core/event_repository.dart';
import 'package:timato/ui/add_event.dart';
// import 'package:timato/ui/add_event.dart';
import 'package:timato/ui/basics.dart';
import 'package:timato/ui/timato_timer_widget.dart';
import 'package:timato/ui/today_task_list.dart';
import 'package:timato/ui/event_list.dart';
import 'dart:developer' as developer;

List<Event> eventsList = [];

// class MyTaskPage extends StatelessWidget {
//   ///newly added
//   //const MyApp1({Key key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // final size = MediaQuery.of(context).size;
//     return MaterialApp(
//       home: ToDoList()
//     );
//   }
// }

class MyTask extends StatefulWidget {
  @override
  _MyTaskState createState() => new _MyTaskState();
}

class _MyTaskState extends State<MyTask> {
  ///A list which contains all the [Event]
  ///
  ///Adds test case1 [testTask] and case2 [testTask2] into [eventList]
  // List eventsList = <Event>[
  //   new Event(taskName: '背单词', eventPriority: Priority.HIGH, tag: 'English'),
  //   new Event(taskName: '写作文', eventPriority: Priority.LOW, tag: 'Chinese'),
  // ];

  ///Turns [eventsList] into [eventsMap]

  @override
  void initState() {
    super.initState();
    getEventList().then((data) {
      setState(() {
        // developer.log("data");
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
            height: 39.0,
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
        onPressed: () {
          AddEvent.showAddEvent(context);
        },
        child: Icon(Icons.add, color: ConstantHelper.tomatoColor),
        backgroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  ///Builds a list of events that is reorderable
  Widget _list() {
    return ReorderableListView(
      // scrollController: ScrollController(),
      children: eventsList.map((task) {
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
                          //   setState((){}),

                          //   SnackBar(content: Text("This task is already part of Today's Tasks", style: TextStyle(color:ConstantHelper.tomatoColor)))
                        } else {
                          task.isTodayList = 1;
                          updateEvent(task);
                          // setState((){
                          //   eventsList = data;
                          // })
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
                          // showDialog(
                          //     context: context,
                          //     builder: (context) {
                          //       Future.delayed(Duration(seconds: 3), () {
                          //         Navigator.of(context).pop(true);
                          //       });
                          //       // return AlertDialog(shape:no,title:Text('Added', style: TextStyle(color: ConstantHelper.tomatoColor)),);
                          //     }),
                          //   Scaffold.of(context).showSnackBar(
                          // SnackBar(content: Text("Added to Today's tasks", style: TextStyle(color:ConstantHelper.tomatoColor)))
                          // );
                          // }
                        }
                      })),
              // setState((){
              //   eventsList = data;
              // })

              IconSlideAction(
                  color: ConstantHelper.tomatoColor,
                  iconWidget: IconButton(
                    icon: Icon(Icons.delete, color: Colors.white),
                    onPressed: () => {
                      deleteEvent(task.id),
                      getEventList().then((data) {
                        setState(() {
                          eventsList = data;
                        });
                      })
                    },
                  )),
              IconSlideAction(
                  color: ConstantHelper.tomatoColor,
                  iconWidget: IconButton(
                    icon: Icon(Icons.receipt, color: Colors.white),
                    onPressed: () => {
                      Navigator.push(context, MaterialPageRoute(builder: (_) {
                        return EventList(task: task, page: "mainList");
                      }))
                    },
                  ))
            ],
            child: ListExpan(task: task));
      }).toList(),
      onReorder: _onReorder,
    );
  }

  ///[onreorder] uses in [ReorderableListView]
  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final Event x = eventsList.removeAt(oldIndex);
      eventsList.insert(newIndex, x);
    });
  }

  /*Widget _event(Event task) {
    return Container(
        key: Key(task.id.toString()),
        margin: EdgeInsets.all(5.0),
        height: 50,
        color: Colors.red[100],
        child: Center(
            child: Text(
          task.taskName,
          style: TextStyle(fontSize: 15, color: Colors.black87),
        )));
  }*/
}

class ListExpan extends StatelessWidget {
  ListExpan({Key key, this.task}) : super(key: key);

  final Event task;

  //const ListExpan(this.task);

  //final Event task;

  Widget _buildTiles(Event task) {
    if (task.subeventsList.isEmpty) return _event(task);
    return Container(
        // constraints: BoxConstraints(maxHeight: 1000),
// width: size.width,
//         height:size.height,
        // height:50,
        color: Colors.white,
        child: ExpansionTile(
          title: _event(task),
          onExpansionChanged: (value) {
            // developer.log("onExpansionChanged");
          },
          children: <Widget>[
            Container(
                height: (50.0 * task.subeventsList.length),
                child: ListView(
                    children: task.subeventsList.map((subtask) {
                  return Slidable(
                      key: task.key,
                      actionPane: SlidableDrawerActionPane(),
                      actionExtentRatio: 0.25,
                      secondaryActions: <Widget>[
                        // IconSlideAction(
                        //     color: ConstantHelper.tomatoColor, icon: Icons.add

                        //     ///Needs onTop in the future
                        //     ),
                        IconSlideAction(
                            color: ConstantHelper.tomatoColor,
                            iconWidget: IconButton(
                              icon: Icon(Icons.delete, color: Colors.white),
                              // onPressed: () => {
                              //   databaseHelper.deleteEvent(task.id),
                              //   databaseHelper.getNoteList().then((data) {
                              //     eventsList = data;
                              //     // setState(() {
                              //     //   eventsList = data;
                              //     // }
                              //     // );
                              //   })
                              // },
                            ))
                      ],
                      child:
                          //return
                          _subevent(subtask));
                }).toList()))
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return _buildTiles(task);
  }

  ///Builds each [Event] on the list
  Widget _event(Event task) {
    return Container(
      key: task.key,
      margin: EdgeInsets.all(5.0),
      height: 50,
      width: 40,
      color: Colors.white,
      child: new Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
                // constraints: BoxConstraints(maxHeight: 1000),
                padding: EdgeInsets.only(top: 3.9),
                child: Icon(Icons.brightness_1,
                    color: ConstantHelper.priorityColor(task))),
            new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Row(children: <Widget>[
                    ///Contains [taskName]
                    Container(
                        // constraints: BoxConstraints(maxHeight: 1000),
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

                  new Row(
                    children: <Widget>[
                      SizedBox(width: 5),
                      _tag(task),
                      // Container(((){
                      //   if(task.tag!=null){

                      //   }
                      // })
                      // constraints: BoxConstraints(maxHeight: 1000),
                      //alignment: Alignment.centerLeft,
                      // child: Text(task.tag,
                      //     style: TextStyle(color: Colors.black87, fontSize: 12)),
                      // decoration: BoxDecoration(
                      //   shape: BoxShape.rectangle,
                      //   borderRadius: BorderRadius.circular(10),
                      //   color: Colors.white,
                      // ),
                      // padding: EdgeInsets.all(2),
                      // ),
                      SizedBox(
                        width: 5,
                        height: 1,
                      ),
                      _ddl(task)
                      // Container(
                      //   // constraints: BoxConstraints(maxHeight: 1000),
                      //   //alignment: Alignment.centerLeft,
                      //   child:
                      //       // if(task.ddl!=null){
                      //       Text(task.ddl.toString(),
                      //           style:
                      //               TextStyle(color: Colors.black87, fontSize: 12)),
                      //   decoration: BoxDecoration(
                      //     shape: BoxShape.rectangle,
                      //     borderRadius: BorderRadius.circular(10),
                      //     color: Colors.white,
                      //   ),
                      //   padding: EdgeInsets.all(2),
                      //   // }
                      // )
                    ],
                  )
                ]),
          ]),
    );
  }

  Widget _tag(Event task) {
    if (task.tag != null) {
      return Container(
        child: Text(task.tag,
            style: TextStyle(color: Colors.black87, fontSize: 12)),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        padding: EdgeInsets.all(2),
      );
    } else {
      return SizedBox(
        width: 0.1,
      );
    }
  }

  Widget _ddl(Event task) {
    if (task.ddl != null) {
      String formatDdl = ddlFormat.formatDate(
          task.ddl, [ddlFormat.yyyy, '-', ddlFormat.mm, '-', ddlFormat.dd]);
      return Container(
        // constraints: BoxConstraints(maxHeight: 1000),
        //alignment: Alignment.centerLeft,
        child:
            // if(task.ddl!=null){
            Text(formatDdl,
                style: TextStyle(color: Colors.black87, fontSize: 12)),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        padding: EdgeInsets.all(2),
        // }
      );
    } else {
      return SizedBox(width: 0.1);
    }
  }

  ///Build each [Subevent] on subevent's list
  Widget _subevent(Subevent subtask) {
    return Container(
      ///key: Key(subtask.id.toString()),
      height: 45,
      color: Colors.white70,
      child: new Row(children: <Widget>[
        SizedBox(
          width: 40,
          height: 1,
        ),
        //Icon(Icons.brightness_1, color: ConstantHelper.priorityColor(subtask)),
        //new Column(
        //children: <Widget>[
        //new Row(
        //children: <Widget>[
        ///Contains [subtaskName]
        Container(
            // constraints: BoxConstraints(maxHeight: 1000),
            margin: EdgeInsets.all(5.0),
            child: Text(subtask.taskName,
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 15, color: Colors.black87)))
      ]),
      //]
      //),
      //]
      //),
    );
  }
}
