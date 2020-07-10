import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/material/colors.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:timato/core/event.dart';
import 'dart:developer' as developer;

class MyApp extends StatelessWidget {
  ///newly added
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ToDoList(),
    );
  }
}

class ToDoList extends StatefulWidget {
  @override
  HomePage createState() => new HomePage();
}

class HomePage extends State<ToDoList> {
  ///A list which contains all the [Event]
  ///
  ///Adds test case1 [testTask] and case2 [testTask2] into [eventList]
  List eventsList = <Event>[
    new Event(
        id: 0,
        taskName: 'test123456789',
        eventPriority: Priority.HIGH,
        tag: 'English'),
    new Event(
        id: 1, taskName: 'test2', eventPriority: Priority.LOW, tag: 'Chinese'),
  ];

  ///Turns [eventsList] into [eventsMap]

  String name = "";
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          title: new Text("My Tasks", style: TextStyle(color: Colors.black87)),
          backgroundColor: Colors.red[400]),
      body: new Container(
        // height: 100,
        decoration: new BoxDecoration(
          color: Colors.white70,
        ),
        child: _list(), //new Column(
        //children: <Widget>[
        //new TextField(
        //decoration: new InputDecoration(
        //hintText: "What is your task?"
        //),
        //onChanged:(String str){
        //setState((){
        //name = str;
        //Event task1 = new Event(name);
        //});
        //})
        //],
      ),
      //)
    );
  }

  ///Builds a list of events that is reorderable
  Widget _list() {
    return ReorderableListView(
      children: eventsList.map((task) {
        return Slidable(
            key: Key(task.id.toString()),
            actionPane: SlidableDrawerActionPane(),
            actionExtentRatio: 0.25,
            secondaryActions: <Widget>[
              IconSlideAction(color: Colors.red[200], icon: Icons.add

                  ///Needs onTop in the future
                  ),
              IconSlideAction(color: Colors.red[200], icon: Icons.delete)
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
        color: Colors.red[300],
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
            key: Key(task.id.toString()),
            actionPane: SlidableDrawerActionPane(),
            actionExtentRatio: 0.25,
            secondaryActions: <Widget>[
              IconSlideAction(color: Colors.red[200], icon: Icons.add

                  ///Needs onTop in the future
                  ),
              IconSlideAction(color: Colors.red[200], icon: Icons.delete)
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
      key: Key(task.id.toString()),
      margin: EdgeInsets.all(5.0),
      height: 50,
      width: 40,
      color: Colors.red[300],
      child: new Row(children: <Widget>[
        Icon(Icons.brightness_1, color: _priorityColor(task)),
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
                            color: Colors.black87,
                            fontWeight: FontWeight.bold)))
              ]),

              ///Contains [tag] and [ddl]

              new Row(
                children: <Widget>[
                  SizedBox(width: 10),
                  Container(
                    //alignment: Alignment.centerLeft,
                    child: Text(task.tag, style: TextStyle(fontSize: 12)),
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
                    child: Text('2029', style: TextStyle(fontSize: 12)),
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
        Icon(Icons.brightness_1, color: _subpriorityColor(subtask)),
        //new Column(
        //children: <Widget>[
        //new Row(
        //children: <Widget>[
        ///Contains [subtaskName]
        Container(
            margin: EdgeInsets.all(5.0),
            child: Text(subtask.subeventName,
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 15, color: Colors.black87)))
      ]),
      //]
      //),
      //]
      //),
    );
  }

  ///Changes the color according to [eventPriority] of [Event]
  Color _priorityColor(Event task) {
    if (task.eventPriority == Priority.HIGH) {
      return Colors.red[700];
    } else if (task.eventPriority == Priority.MIDDLE) {
      return Colors.orange;
    } else if (task.eventPriority == Priority.LOW) {
      return Colors.blue[300];
    } else {
      return Colors.white;
    }
  }

  Color _subpriorityColor(Subevent subtask) {
    if (subtask.subeventPriority == Priority.HIGH) {
      return Colors.red[700];
    } else if (subtask.subeventPriority == Priority.MIDDLE) {
      return Colors.orange;
    } else if (subtask.subeventPriority == Priority.LOW) {
      return Colors.blue[300];
    } else {
      return Colors.white;
    }
  }
}
