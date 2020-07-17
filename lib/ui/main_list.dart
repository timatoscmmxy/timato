import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/material/colors.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:timato/core/event.dart';
import 'package:timato/ui/basics.dart';
import 'package:timato/core/db.dart';
import 'package:timato/ui/event_list.dart';
import 'dart:developer' as developer;

List<Event> eventsList = [];

class MyApp1 extends StatelessWidget {
  ///newly added
  //const MyApp1({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ToDoList(),
    );
  }
}

class ToDoList extends StatefulWidget {
  @override
  MainList createState() => new MainList();
}

class MainList extends State<ToDoList> {
  ///For database
  DatabaseHelper databaseHelper = DatabaseHelper();

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
    developer.log('got here');
    // databaseHelper.insertEvent(Event(taskName: '背单词1', eventPriority: Priority.HIGH, tag: 'English')).then((id){    developer.log(id.toString());});
    // databaseHelper.insertEvent(Event(taskName: '背单词2', eventPriority: Priority.LOW, tag: 'Chinese')).then((id){    developer.log(id.toString());});
    // databaseHelper.insertEvent(Event(taskName: '背单词3', eventPriority: Priority.MIDDLE, tag: 'English')).then((id){    developer.log(id.toString());});
    // databaseHelper.getNoteList().then((data) {
    //   data.forEach((element) {
    //     databaseHelper.deleteEvent(element.id);
    //   });
    //   // setState(() {
    //   //   eventsList = data;
    //   // });
    // });
    databaseHelper
        .insertEvent(Event(
            taskName: '背单词1', eventPriority: Priority.HIGH, tag: 'English'));
      //   .then((id) {
      // developer.log(id.toString());
    // }
    // );
    databaseHelper
        .insertEvent(Event(
            taskName: '背单词2', eventPriority: Priority.LOW, tag: 'Chinese'));
    //     .then((id) {
    //   developer.log(id.toString());
    // });
    databaseHelper
        .insertEvent(Event(
            taskName: '背单词3', eventPriority: Priority.MIDDLE, tag: 'English'));
    //     .then((id) {
    //   developer.log(id.toString());
    // });
    databaseHelper.getEventList().then((data) {
      setState(() {
        eventsList = data;
      });
    });
  }

  String name = "";
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          title: new Text("My Tasks",
              style: TextStyle(color: ConstantHelper.tomatoColor)),
          backgroundColor: Colors.white),
      body: new Container(
        // height: 100,
        decoration: new BoxDecoration(
          color: Colors.white,
        ),
        child: _list(),
      ),
    );
  }

  ///Builds a list of events that is reorderable
  Widget _list() {
    return ReorderableListView(
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
                  )

                  ///Needs onTop in the future
                  ),
              IconSlideAction(
                  color: ConstantHelper.tomatoColor,
                  iconWidget: IconButton(
                    icon: Icon(Icons.delete, color: Colors.white),
                    onPressed: () => {
                      databaseHelper.deleteEvent(task.id),
                      databaseHelper.getEventList().then((data) {
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
                        return EventList(task: task);
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

  DatabaseHelper databaseHelper = DatabaseHelper();

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
                        IconSlideAction(
                            color: ConstantHelper.tomatoColor, icon: Icons.add

                            ///Needs onTop in the future
                            ),
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
        Icon(Icons.brightness_1, color: ConstantHelper.priorityColor(task)),
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
                            color: ConstantHelper.tomatoColor,
                            fontWeight: FontWeight.bold)))
              ]),

              ///Contains [tag] and [ddl]

              new Row(
                children: <Widget>[
                  SizedBox(width: 10),
                  Container(
                    //alignment: Alignment.centerLeft,
                    child: Text(task.tag,
                        style: TextStyle(
                            color: ConstantHelper.tomatoColor, fontSize: 12)),
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.all(2),
                  ),
                  SizedBox(width: 5),
                  Container(
                    //alignment: Alignment.centerLeft,
                    child: Text('2029',
                        style: TextStyle(
                            color: ConstantHelper.tomatoColor, fontSize: 12)),
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
        SizedBox(width: 25),
        Icon(Icons.brightness_1, color: ConstantHelper.priorityColor(subtask)),
        //new Column(
        //children: <Widget>[
        //new Row(
        //children: <Widget>[
        ///Contains [subtaskName]
        Container(
            margin: EdgeInsets.all(5.0),
            child: Text(subtask.taskName,
                textAlign: TextAlign.left,
                style:
                    TextStyle(fontSize: 15, color: ConstantHelper.tomatoColor)))
      ]),
      //]
      //),
      //]
      //),
    );
  }
}
