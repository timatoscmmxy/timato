import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/material/colors.dart';

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
  ///ToDoList({Key key}) : super(key: key);

  ///ToDoList({Key key, this.taskName}) : super(key: key);

  ///final String taskName;

  @override
  HomePage createState() => new HomePage();
}

class HomePage extends State<ToDoList> {
  // ///Test case1
  // Event testTask = new Event('test1');

  // ///Test case2
  // Event testTask2 = new Event('test2');

  ///A list which contains all the [Event]
  ///
  ///Adds test case1 [testTask] and case2 [testTask2] into [eventList]
  List eventsList = <Event>[
    new Event(id: 0, taskName: 'test1', ddl: DateTime(2029)),
    new Event(id: 1, taskName: 'test2', ddl: DateTime(2021)),
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
          color: Colors.red[400],
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
        return ListExpan(key: Key(task.id.toString()), task: task);
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
    return ExpansionTile(
      title: _event(task),
      onExpansionChanged: (value) {
        // developer.log("onExpansionChanged");
      },
      children: <Widget>[
        Container(
            height: (50.0 * task.subeventsList.length),
            child: ListView(
                children: task.subeventsList.map((subtask) {
              return _subevent(subtask);
            }).toList()))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTiles(task);
  }

  Widget _event(Event task) {
    return Container(
        key: Key(task.id.toString()),
        margin: EdgeInsets.all(5.0),
        height: 50,
        width: 40,
        color: Colors.red[100],
        child: Center(
          child: new Row(children: <Widget>[
            Icon(Icons.brightness_1, color: Colors.red),
            new Column(children: <Widget>[
              Text(task.taskName),
              new Row(
                children: <Widget>[
                  Container(color: Colors.white, child: Text('tag')),
                  Container(color: Colors.white, child: Text('ddl'))
                ],
              )
            ]),
          ]),
        ));
  }

  Widget _subevent(Subevent subtask) {
    return Container(

        ///key: Key(subtask.id.toString()),
        height: 45,
        color: Colors.white70,
        child: Center(
            child: Text(
          subtask.subeventName,
          // style: TextStyle(fontSize: 12, color: Colors.black87),
        )));
  }
}
