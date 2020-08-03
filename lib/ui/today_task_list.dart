import 'dart:developer' as developer;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/material/colors.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:timato/core/event.dart';
import 'package:timato/core/event_repository.dart';
import 'package:timato/ui/basics.dart';
import 'package:timato/ui/main_list.dart';
import 'package:timato/ui/event_list.dart';
import 'package:timato/ui/settings_widget.dart';
import 'package:timato/ui/timato_timer_widget.dart';

// List<Event> todayEventList = [];

List<Subevent> subeventListFake = [
  new Subevent(taskName: 'subevent1'),
  new Subevent(taskName: 'subevent2'),
  new Subevent(taskName: 'subevent3')
];

List<Event> unplanned = [new Event(taskName: '回邮件')];

// class TodayListPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: TodayList(),
//     );
//   }
// }
String unplannedDuration;

class TodayList extends StatefulWidget {
  @override
  _TodayListState createState() => new _TodayListState();
}

class _TodayListState extends State<TodayList> {
  EventRepository databaseHelper = EventRepository();

  ///Build each [Subevent] on subevent's list
  // Widget _subevent(Subevent subtask) {
  //   return Container(
  //     ///key: Key(subtask.id.toString()),
  //     height: 35,
  //     color: Colors.white70,
  //     child: new Row(children: <Widget>[
  //       SizedBox(width: 40),
  //       //Icon(Icons.brightness_1, color: ConstantHelper.priorityColor(subtask)),
  //       //new Column(
  //       //children: <Widget>[
  //       //new Row(
  //       //children: <Widget>[
  //       ///Contains [subtaskName]
  //       Container(
  //           // padding: EdgeInsets.all(10.0),
  //           // margin: EdgeInsets.all(10.0),
  //           child:
  //           Column(children: <Widget>[
  //             SizedBox(height:10),
  //             Text(subtask.taskName,
  //               // textAlign: TextAlign.end,
  //               style: TextStyle(fontSize: 15, color: Colors.black87))
  //           ],)
  //           )
  //     ]),
  //     //]
  //     //),
  //     //]
  //     //),
  //   );
  // }

  @override
  void initState() {
    // databaseHelper.insertEvent(new Event(taskName: '回邮件', isTodayList: 1, isUnplanned: 1));
    // databaseHelper.insertEvent(new Event(taskName: '打电话', isTodayList: 1, isUnplanned: 1));
    databaseHelper.getTodayEventList().then((data) {
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
            // leading: IconButton(
            //     icon: Icon(Icons.view_list, color: ConstantHelper.tomatoColor),
            //     onPressed: null),
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
        drawer: new SideBar('TodayList'));
  }

  Widget _todayList() {
    EventRepository databaseHelper = EventRepository();
    //return ListView(
    // children: <Widget> [
    //return Container(
    //height: double.infinity,
    //child:
    // return ListView(
    //   shrinkWrap: true,
    //   physics: NeverScrollableScrollPhysics(),
    //  return Scaffold(
    return ReorderableListView(
      // children:<Widget>[
      // children: <Widget>[
      // _buildTiles(task);
      children: todayEventList.map(
        (task) {
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
                                        title: 'Delete this Unplanned event?',
                                        text:
                                            'Are you sure to delete this Unplanned event permanently?',
                                        context: context,
                                        action: (context) {
                                          databaseHelper.deleteEvent(task.id);
                                          databaseHelper
                                              .getTodayEventList()
                                              .then((data) {
                                            setState(() {
                                              todayEventList = data;
                                            });
                                          });
                                          // Navigator.pop(context);
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
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (_) {
                                return TimatoTimerWidget(
                                    timerLength: timerLength,
                                    relaxLength: relaxLength,
                                    event: task,
                                    clockNum: currentClockNum);
                              }));
                            },
                          ))
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
            return InkWell(
                key: task.key,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return EventList(task: task, page: "todayList");
                  }));
                },
                child: Container(
                    height: (30.0 * task.subeventsList.length
                        // task.subeventsList.length
                        +
                        61),
                    width: MediaQuery.of(context).size.width,
                    color: Colors.white,
                    child: new Column(
                      children: <Widget>[
                        Slidable(
                            // key: task.key,
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
                                                  databaseHelper
                                                      .updateEvent(task)
                                                      .then((id) {
                                                    databaseHelper
                                                        .getTodayEventList()
                                                        .then((data) {
                                                      setState(() {
                                                        todayEventList = data;
                                                      });
                                                    });
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
                                      List<int> timerData =
                                          await getTimerData();
                                      int timerLength = timerData[0];
                                      int relaxLength = timerData[1];
                                      int currentClockNum = await task.clockNum;
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (_) {
                                        return TimatoTimerWidget(
                                            timerLength: timerLength,
                                            relaxLength: relaxLength,
                                            event: task,
                                            clockNum: currentClockNum);
                                      }));
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
                                            child: Icon(Icons.brightness_1,
                                                color: ConstantHelper
                                                    .priorityColor(task))),
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
                                                        textAlign:
                                                            TextAlign.left,
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
                                                  SizedBox(
                                                    width: 5,
                                                    height: 1,
                                                  ),
                                                  _ddl(task)
                                                ],
                                              ),
                                            ]),
                                      ]),
                                  _sublist(task),
                                  SizedBox(height: 4),
                                  // Divider(color: Colors.grey[350],height:1)
                                ]))),
                        Divider(color: Colors.grey[350], height: 1)
                      ],
                    )));
          }
        },
        // UnplannedExpan()
      ).toList(),

      // UnplannedExpan(),
      onReorder: _onReorder,
      // ]
      // )
    );
    //  ]
    //   //)
    // );
  }

  ///[onreorder] uses in [ReorderableListView]
  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final Event x = todayEventList.removeAt(oldIndex);
      todayEventList.insert(newIndex, x);
    });
  }

  Widget _sublist(Event task) {
    if (task.subeventsList != null) {
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
              height: 30.0 * (task.subeventsList.length),
              child: ListView(
                primary: false,
                physics: const NeverScrollableScrollPhysics(),
                children: task.subeventsList.map((subtask) {
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
    // else{
    //   return SizedBox(height: 0,);
    // }
  }

  Widget _tag(Event task) {
    if (task.tag != null) {
      return Container(
        child: Text(task.tag,
            style: TextStyle(color: Colors.black87, fontSize: 12)),
        decoration: BoxDecoration(
          // border:Border.all(color:Colors.grey[350]),
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
      return Container(
        // constraints: BoxConstraints(maxHeight: 1000),
        //alignment: Alignment.centerLeft,
        child:
            // if(task.ddl!=null){
            Text(task.ddl.toString(),
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
}

// class ListExpan extends StatefulWidget {
//   ListExpan({Key key, this.task}) : super(key: key);

//   final Event task;

//   EventRepository databaseHelper = EventRepository();
//   @override
//   _ListExpanState createState() => _ListExpanState(task);
// }

// class _ListExpanState extends State<ListExpan> {
//   _ListExpanState(this.task);

//   final Event task;

//   EventRepository databaseHelper = EventRepository();

//   @override
//   Widget build(BuildContext context) {
//     if (task.subeventsList.isEmpty) return _event(task);
//     return Container(
//         color: Colors.white,
//         child: ExpansionTile(
//           title: _event(task),
//           onExpansionChanged: (value) {
//             // developer.log("onExpansionChanged");
//           },
//           children: <Widget>[
//             Container(
//                 height: (50.0 * task.subeventsList.length),
//                 child: ListView(
//                     children: task.subeventsList.map((subtask) {
//                   return Slidable(
//                       key: task.key,
//                       actionPane: SlidableDrawerActionPane(),
//                       actionExtentRatio: 0.25,
//                       secondaryActions: <Widget>[
//                         // IconSlideAction(
//                         //     color: ConstantHelper.tomatoColor, icon: Icons.add

//                         //     ///Needs onTop in the future
//                         //     ),
//                         IconSlideAction(
//                             color: ConstantHelper.tomatoColor,
//                             iconWidget: IconButton(
//                                 icon: Icon(Icons.delete, color: Colors.white),
//                                 onPressed: () => {
//                                       WarningDialog.show(
//                                           title: 'Delete this subtask?',
//                                           text:
//                                               'Are you sure to delete this subtask permanently?',
//                                           context: context,
//                                           action: (context) {
//                                             databaseHelper.deleteEvent(task.id);
//                                             databaseHelper
//                                                 .getTodayEventList()
//                                                 .then((data) {
//                                               setState(() {
//                                                 todayEventList = data;
//                                               });
//                                             });
//                                             // Navigator.pop(context);
//                                           })
//                                       // databaseHelper.deleteEvent(task.id),
//                                       // databaseHelper.getTodayEventList().then((data) {
//                                       //   setState(() {
//                                       //     todayEventList = data;
//                                       //   });
//                                     }
//                                 // onPressed: () => {
//                                 //   databaseHelper.deleteEvent(task.id),
//                                 //   databaseHelper.getNoteList().then((data) {
//                                 //     eventsList = data;
//                                 //     // setState(() {
//                                 //     //   eventsList = data;
//                                 //     // }
//                                 //     // );
//                                 //   })
//                                 // },
//                                 ))
//                       ],
//                       child:
//                           //return
//                           _subevent(subtask));
//                 }).toList())
//                 )
//           ],
//         ));

//     // );
//   }

///Builds each [Event] on the list
// Widget _event(Event task) {
//   return Container(
//     key: task.key,
//     margin: EdgeInsets.all(5.0),
//     height: 50,
//     width: 40,
//     color: Colors.white,
//     child: new Row(children: <Widget>[
//       Container(
//           padding: EdgeInsets.only(top: 0),
//           child: Icon(Icons.brightness_1,
//               color: ConstantHelper.priorityColor(task))),
//       new Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             new Row(children: <Widget>[
//               ///Contains [taskName]
//               Container(
//                   margin: EdgeInsets.all(5.0),
//                   child: Text(task.taskName,
//                       textAlign: TextAlign.left,
//                       style: TextStyle(
//                         fontSize: 15,
//                         color: Colors.black87,
//                         //fontWeight: FontWeight.bold
//                       )))
//             ]),

//             ///Contains [tag] and [ddl]

//             new Row(
//               children: <Widget>[
//                 SizedBox(width: 10),
//                 // _tag(task),
//                 SizedBox(
//                   width: 5,
//                   height: 1,
//                 ),
//                 // _ddl(task)
//               ],
//             )
//           ]),
//     ]),
//   );
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
//     return Container(
//       // constraints: BoxConstraints(maxHeight: 1000),
//       //alignment: Alignment.centerLeft,
//       child:
//           // if(task.ddl!=null){
//           Text(task.ddl.toString(),
//               style: TextStyle(color: Colors.black87, fontSize: 12)),
//       decoration: BoxDecoration(
//         shape: BoxShape.rectangle,
//         borderRadius: BorderRadius.circular(10),
//         color: Colors.white,
//       ),
//       padding: EdgeInsets.all(2),
//       // }
//     );
//   } else {
//     return SizedBox(width: 0.1);
//   }
// }

// ///Build each [Subevent] on subevent's list
// Widget _subevent(Subevent subtask) {
//   return Container(
//     ///key: Key(subtask.id.toString()),
//     height: 45,
//     color: Colors.white70,
//     child: new Row(children: <Widget>[
//       SizedBox(width: 40),
//       //Icon(Icons.brightness_1, color: ConstantHelper.priorityColor(subtask)),
//       //new Column(
//       //children: <Widget>[
//       //new Row(
//       //children: <Widget>[
//       ///Contains [subtaskName]
//       Container(
//           margin: EdgeInsets.all(5.0),
//           child: Text(subtask.taskName,
//               textAlign: TextAlign.left,
//               style: TextStyle(fontSize: 15, color: Colors.black87)))
//     ]),
//     //]
//     //),
//     //]
//     //),
//   );
// }
// }
