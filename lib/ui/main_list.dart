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

class MyTask extends StatefulWidget {
  @override
  _MyTaskState createState() => new _MyTaskState();
}

class _MyTaskState extends State<MyTask> {
// List<Event> todayEventList = [];
// List<Event> eventsList = [];
// List<Event> subtasksList=[];
  @override
  void initState() {
    // super.initState();
    // deleteEvent(eventsList[1].id);
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
    developer.log(eventsList.toString());
    // getEventList().then((data) {
    //   setState(() {
    //     eventsList = data;
    //   });
    // });
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
        onPressed: () async {
          AddEvent.showAddEvent(context, (e) {
            getEventList().then(
              (data) {
                setState(() {
                  eventsList = data;
                });
              },
            );
            // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) {
            //   return MyTask();
            // }));
          });
          // getEventList().then((data) {
          //   setState(() {
          //     eventsList = data;
          //   });
          // });
          //TODO: when add a new event, update its taskOrder
        },
        child: Icon(Icons.add, color: ConstantHelper.tomatoColor),
        backgroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void _subtasksListHelper(Event task) async {
    subtasksList = await getSubevent(task);
  }

  ///Builds a list of events that is reorderable
  Widget _list() {
    return ReorderableListView(
      // scrollController: ScrollController(),
      children: eventsList.map((task) {
        if (task.isUnplanned == 1) {
          return Container(
              key: task.key,
              height: 50,
              child: Slidable(
                  // key: task.key,
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
                                        // Navigator.pop(context);
                                      })
                                })),
                  ],
                  child: Container(
                      // height: constrains.maxHeight,
                      margin: EdgeInsets.all(5.0),
                      // height: 50,
                      child: new Row(
                        children: <Widget>[
                          SizedBox(width: 15),
                          Icon(Icons.warning,
                              color: ConstantHelper.tomatoColor),
                          SizedBox(width: 5),
                          Text(task.taskName,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                                //fontWeight: FontWeight.bold
                              ))
                        ],
                      ))));
        } else {
          _subtasksListHelper(task);
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
                            var data = WarningDialog.show(
                                title: "Add to today's tasks?",
                                text:
                                    "Are you sure to add this task to today's tasks?",
                                context: context,
                                action: (context) {
                                  // task.isTodayList = 1;
                                  getTodayEventList().then(
                                    (data) {
                                      setState(() {
                                        todayEventList = data;
                                      });
                                    },
                                  );
                                  // int count = todayEventList.last.todayOrder+1;
                                  if(todayEventList.length==0){
                                    task.todayOrder=0;
                                  }else{
                                    developer.log('taskname'+todayEventList.last.taskName);
                                    // developer.log('todayorder'+todayEventList.last.);
                                  task.todayOrder = todayEventList.last.todayOrder+1;}
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
                // setState((){
                //   eventsList = data;
                // })

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
                      onPressed: () => {
                        Navigator.push(context, MaterialPageRoute(builder: (_) {
                          return EventList(task: task, page: "mainList");
                        }))
                      },
                    ))
              ],
              child: ListExpan(task: task, subtasksList: subtasksList));
        }
      }).toList(),
      onReorder: _onReorder,
    );
  }

  ///[onreorder] uses in [ReorderableListView]
  void _onReorder(int oldIndex, int newIndex) {
    developer.log('new index' + newIndex.toString());
    // setState(() {
    if (oldIndex < newIndex) {
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
    // });
  }
}

class ListExpan extends StatefulWidget {
  ListExpan({Key key, this.task, this.subtasksList}) : super(key: key);

  final Event task;
  List<Event> subtasksList;
  @override
  _ListExpanState createState() =>
      _ListExpanState(task: task, subtasksList: subtasksList);
}

class _ListExpanState extends State<ListExpan> {
  _ListExpanState({this.task, this.subtasksList});

  final Event task;
  List<Event> subtasksList;
  @override
  Widget build(BuildContext context) {
    return _buildTiles(task);
  }

  Widget _buildTiles(Event task) {
    if (subtasksList == []) {
      return _event(task);
    } else {
      return Container(
          color: Colors.white,
          child: ExpansionTile(
            title: _event(task),
            onExpansionChanged: (value) {
              // developer.log("onExpansionChanged");
            },
            children: <Widget>[
              Container(
                  height: (50.0 * subtasksList.length),
                  child: ListView(
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
                                              setState(() {
                                                subtasksList = data;
                                              });
                                            });
                                          })
                                    },
                                  ))
                            ],
                            child:
                                //return
                                _subevent(subtask));
                      }).toList()))
            ],
          ));
    }
  }

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
                  tagDdl(task)
                  // new Row(
                  //   children: <Widget>[
                  //     SizedBox(width: 5),
                  //     _tag(task),
                  //     SizedBox(
                  //       width: 5,
                  //       height: 1,
                  //     ),
                  //     _ddl(task)
                  //   ],
                  // )
                ]),
          ]),
    );
  }

  Widget tagDdl(Event task) {
    developer.log('tag' + task.tag);
    if (task.tag == null && task.ddl == null) {
      return SizedBox();
    } else {
      return new Row(
        children: <Widget>[
          SizedBox(width: 5),
          _tag(task),
          SizedBox(
            width: 5,
            height: 1,
          ),
          _ddl(task)
        ],
      );
    }
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
      return SizedBox();
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
  Widget _subevent(Event subtask) {
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

// class ListExpan extends StatelessWidget {
//   ListExpan({Key key, this.task, this.subtasksList}) : super(key: key);

//   final Event task;
//   final List<Event> subtasksList;

// Widget _buildTiles(Event task) {
//   if (subtasksList.isEmpty) return _event(task);
//   return Container(
//       color: Colors.white,
//       child: ExpansionTile(
//         title: _event(task),
//         onExpansionChanged: (value) {
//           // developer.log("onExpansionChanged");
//         },
//         children: <Widget>[
//           Container(
//               height: (50.0 * subtasksList.length),
//               child: ListView(
//                   children: subtasksList.map((subtask) {
//                 return Slidable(
//                     key: task.key,
//                     actionPane: SlidableDrawerActionPane(),
//                     actionExtentRatio: 0.25,
//                     secondaryActions: <Widget>[
//                       IconSlideAction(
//                           color: ConstantHelper.tomatoColor,
//                           iconWidget: IconButton(
//                             icon: Icon(Icons.delete, color: Colors.white),
//                             onPressed: () => {
//                     WarningDialog.show(
//                         title: 'Delete this task?',
//                         text: 'Are you sure to delete this task?',
//                         context: context,
//                         action: (context) {
//                           deleteEvent(task.id);
//                           getEventList().then((data) {
//                             setState(() {
//                               eventsList = data;
//                             });
//                           });
//                         })
//                   },
//                           ))
//                     ],
//                     child:
//                         //return
//                         _subevent(subtask));
//               }).toList()))
//         ],
//       ));
// }

// @override
// Widget build(BuildContext context) {
//   return _buildTiles(task);
// }

///Builds each [Event] on the list
//   Widget _event(Event task) {
//     return Container(
//       key: task.key,
//       margin: EdgeInsets.all(5.0),
//       height: 50,
//       width: 40,
//       color: Colors.white,
//       child: new Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             Container(
//                 // constraints: BoxConstraints(maxHeight: 1000),
//                 padding: EdgeInsets.only(top: 3.9),
//                 child: Icon(Icons.brightness_1,
//                     color: ConstantHelper.priorityColor(task))),
//             new Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: <Widget>[
//                   new Row(children: <Widget>[
//                     ///Contains [taskName]
//                     Container(
//                         // constraints: BoxConstraints(maxHeight: 1000),
//                         margin: EdgeInsets.all(5.0),
//                         child: Text(task.taskName,
//                             textAlign: TextAlign.left,
//                             style: TextStyle(
//                               fontSize: 16,
//                               color: Colors.black87,
//                               //fontWeight: FontWeight.bold
//                             )))
//                   ]),

//                   ///Contains [tag] and [ddl]

//                   new Row(
//                     children: <Widget>[
//                       SizedBox(width: 5),
//                       _tag(task),
//                       // Container(((){
//                       //   if(task.tag!=null){

//                       //   }
//                       // })
//                       // constraints: BoxConstraints(maxHeight: 1000),
//                       //alignment: Alignment.centerLeft,
//                       // child: Text(task.tag,
//                       //     style: TextStyle(color: Colors.black87, fontSize: 12)),
//                       // decoration: BoxDecoration(
//                       //   shape: BoxShape.rectangle,
//                       //   borderRadius: BorderRadius.circular(10),
//                       //   color: Colors.white,
//                       // ),
//                       // padding: EdgeInsets.all(2),
//                       // ),
//                       SizedBox(
//                         width: 5,
//                         height: 1,
//                       ),
//                       _ddl(task)
//                       // Container(
//                       //   // constraints: BoxConstraints(maxHeight: 1000),
//                       //   //alignment: Alignment.centerLeft,
//                       //   child:
//                       //       // if(task.ddl!=null){
//                       //       Text(task.ddl.toString(),
//                       //           style:
//                       //               TextStyle(color: Colors.black87, fontSize: 12)),
//                       //   decoration: BoxDecoration(
//                       //     shape: BoxShape.rectangle,
//                       //     borderRadius: BorderRadius.circular(10),
//                       //     color: Colors.white,
//                       //   ),
//                       //   padding: EdgeInsets.all(2),
//                       //   // }
//                       // )
//                     ],
//                   )
//                 ]),
//           ]),
//     );
//   }

//   Widget _tag(Event task) {
//     if (task.tag != null) {
//       return Container(
//         child: Text(task.tag,
//             style: TextStyle(color: Colors.black87, fontSize: 12)),
//         decoration: BoxDecoration(
//           shape: BoxShape.rectangle,
//           borderRadius: BorderRadius.circular(10),
//           color: Colors.white,
//         ),
//         padding: EdgeInsets.all(2),
//       );
//     } else {
//       return SizedBox(
//         width: 0.1,
//       );
//     }
//   }

//   Widget _ddl(Event task) {
//     if (task.ddl != null) {
//       String formatDdl = ddlFormat.formatDate(
//           task.ddl, [ddlFormat.yyyy, '-', ddlFormat.mm, '-', ddlFormat.dd]);
//       return Container(
//         // constraints: BoxConstraints(maxHeight: 1000),
//         //alignment: Alignment.centerLeft,
//         child:
//             // if(task.ddl!=null){
//             Text(formatDdl,
//                 style: TextStyle(color: Colors.black87, fontSize: 12)),
//         decoration: BoxDecoration(
//           shape: BoxShape.rectangle,
//           borderRadius: BorderRadius.circular(10),
//           color: Colors.white,
//         ),
//         padding: EdgeInsets.all(2),
//         // }
//       );
//     } else {
//       return SizedBox(width: 0.1);
//     }
//   }

//   ///Build each [Subevent] on subevent's list
//   Widget _subevent(Event subtask) {
//     return Container(
//       ///key: Key(subtask.id.toString()),
//       height: 45,
//       color: Colors.white70,
//       child: new Row(children: <Widget>[
//         SizedBox(
//           width: 40,
//           height: 1,
//         ),
//         //Icon(Icons.brightness_1, color: ConstantHelper.priorityColor(subtask)),
//         //new Column(
//         //children: <Widget>[
//         //new Row(
//         //children: <Widget>[
//         ///Contains [subtaskName]
//         Container(
//             // constraints: BoxConstraints(maxHeight: 1000),
//             margin: EdgeInsets.all(5.0),
//             child: Text(subtask.taskName,
//                 textAlign: TextAlign.left,
//                 style: TextStyle(fontSize: 15, color: Colors.black87)))
//       ]),
//       //]
//       //),
//       //]
//       //),
//     );
//   }
// }
