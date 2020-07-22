import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/material/colors.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:timato/core/event.dart';
import 'package:timato/core/event_repository.dart';
import 'package:timato/ui/basics.dart';
import 'package:timato/ui/main_list.dart';
import 'package:timato/ui/event_list.dart';
import 'dart:developer' as developer;

List<Event> todayEventList = [];

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
                  onPressed: () {
                    // Navigator.push(context, MaterialPageRoute(builder: (_){
                    //   return
                    // }))
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
            return Slidable(
                key: task.key,
                actionPane: SlidableDrawerActionPane(),
                actionExtentRatio: 0.25,
                secondaryActions: <Widget>[
                  IconSlideAction(
                      color: ConstantHelper.tomatoColor,
                      iconWidget: IconButton(
                        icon: Icon(Icons.delete, color: Colors.white),
                        onPressed: () => {
                          databaseHelper.deleteEvent(task.id),
                          databaseHelper.getTodayEventList().then((data) {
                            setState(() {
                              todayEventList = data;
                            });
                          })
                        },
                      )),
                  IconSlideAction(
                      color: ConstantHelper.tomatoColor,
                      iconWidget: IconButton(
                        icon: Icon(Icons.play_circle_outline,
                            color: Colors.white),
                        onPressed: () => {
                          AlertDialog(
                              title: Text('How long will this take?'),
                              content: TextFormField(
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.done,
                                inputFormatters: [
                                  WhitelistingTextInputFormatter.digitsOnly
                                ],
                                maxLength: 3,
                                decoration: const InputDecoration(
                                    suffixText: 'minutes',
                                    counterText: '',
                                    border: InputBorder.none),
                                onChanged:(text){
                                  unplannedDuration = text;
                                  print('$unplannedDuration');
                                }
                              ),
                              actions:<Widget>[
                                new FlatButton(
                                  child: new Text('Cancel'),
                                  onPressed:(){
                                    Navigator.of(context).pop();
                                  },),
                                  new FlatButton(child: new Text("Start clock"),
                                  onPressed: (){
                                  task.duration = int.parse(unplannedDuration);
                                  //TODO:continue
                                  },)
                              ])
                          // databaseHelper.deleteEvent(task.id),
                          // databaseHelper.getTodayEventList().then((data) {
                          //   setState(() {
                          //     todayEventList = data;
                          //   });
                          // })
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
                        Icon(Icons.warning, color: ConstantHelper.tomatoColor),
                        SizedBox(width: 5),
                        Text(task.taskName,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                              //fontWeight: FontWeight.bold
                            ))
                      ],
                    )));
          }
          return Slidable(
              key: task.key,
              actionPane: SlidableDrawerActionPane(),
              actionExtentRatio: 0.25,
              secondaryActions: <Widget>[
                IconSlideAction(
                    color: ConstantHelper.tomatoColor,
                    iconWidget: IconButton(
                        icon: Icon(Icons.delete_sweep, color: Colors.white),
                        onPressed: () => {
                              // setState((){
                              //   task.isTodayList = 0;
                              // }),
                              task.isTodayList = 0,
                              databaseHelper.updateEvent(task).then((id) {
                                databaseHelper.getTodayEventList().then((data) {
                                  setState(() {
                                    todayEventList = data;
                                  });
                                });
                              })
                            })

                    ///Needs onTop in the future
                    ),
                IconSlideAction(
                    color: ConstantHelper.tomatoColor,
                    iconWidget: IconButton(
                      icon: Icon(Icons.delete, color: Colors.white),
                      onPressed: () => {
                        databaseHelper.deleteEvent(task.id),
                        databaseHelper.getTodayEventList().then((data) {
                          setState(() {
                            todayEventList = data;
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
                          return EventList(task: task);
                        }))
                      },
                    ))
              ],
              child: ListExpan(task: task));
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
}

class ListExpan extends StatelessWidget {
  ListExpan({Key key, this.task}) : super(key: key);

  final Event task;

  EventRepository databaseHelper = EventRepository();

  //const ListExpan(this.task);

  //final Event task;

  Widget _buildTiles(Event task) {
    if (task.subeventsList.isEmpty) return _event(task);
    return Container(
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
      child: new Row(children: <Widget>[
        Container(
            padding: EdgeInsets.only(top: 0),
            child: Icon(Icons.brightness_1,
                color: ConstantHelper.priorityColor(task))),
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
                          fontSize: 15,
                          color: Colors.black87,
                          //fontWeight: FontWeight.bold
                        )))
              ]),

              ///Contains [tag] and [ddl]

              new Row(
                children: <Widget>[
                  SizedBox(width: 10),
                  // Container(
                  //   //alignment: Alignment.centerLeft,
                  //   child: Text(task.tag,
                  //       style: TextStyle(
                  //           color: Colors.black87, fontSize: 12)),
                  //   decoration: BoxDecoration(
                  //     shape: BoxShape.rectangle,
                  //     borderRadius: BorderRadius.circular(10),
                  //     color: Colors.white,
                  //   ),
                  //   padding: EdgeInsets.all(2),
                  // ),
                  // SizedBox(width: 5),
                  Container(
                    //alignment: Alignment.centerLeft,
                    child: Text('2029',
                        style: TextStyle(color: Colors.black87, fontSize: 12)),
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.all(2),
                  )
                ],
              )
            ]),
      ]),
    );
  }

  ///Build each [Subevent] on subevent's list
  Widget _subevent(Subevent subtask) {
    return Container(
      ///key: Key(subtask.id.toString()),
      height: 45,
      color: Colors.white70,
      child: new Row(children: <Widget>[
        SizedBox(width: 40),
        //Icon(Icons.brightness_1, color: ConstantHelper.priorityColor(subtask)),
        //new Column(
        //children: <Widget>[
        //new Row(
        //children: <Widget>[
        ///Contains [subtaskName]
        Container(
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

// class UnplannedExpan extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return _buildTiles();
//   }

//   }

//  Widget _buildTiles() {
//   return Container(
//       color: Colors.white,
//       child: ExpansionTile(
//         title: Text('Unplanned Things'),
//         onExpansionChanged: (value) {
//           // developer.log("onExpansionChanged");
//         },
//         children: <Widget>[
//           Container(
//               height: (50.0 * task.subeventsList.length),
//               child: ListView(
//                   children: task.subeventsList.map((subtask) {
//                 return Slidable(
//                     key: task.key,
//                     actionPane: SlidableDrawerActionPane(),
//                     actionExtentRatio: 0.25,
//                     secondaryActions: <Widget>[
//                       // IconSlideAction(
//                       //     color: ConstantHelper.tomatoColor, icon: Icons.add

//                       //     ///Needs onTop in the future
//                       //     ),
//                       IconSlideAction(
//                           color: ConstantHelper.tomatoColor,
//                           iconWidget: IconButton(
//                             icon: Icon(Icons.delete, color: Colors.white),
//                             // onPressed: () => {
//                             //   databaseHelper.deleteEvent(task.id),
//                             //   databaseHelper.getNoteList().then((data) {
//                             //     eventsList = data;
//                             //     // setState(() {
//                             //     //   eventsList = data;
//                             //     // }
//                             //     // );
//                             //   })
//                             // },
//                           ))
//                     ],
//                     child:
//                         //return
//                         _subevent(subtask));
//               }).toList()))
//         ],
//       ));
// }
// }
