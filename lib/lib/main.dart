import 'package:flutter/material.dart';
import 'package:flutter/src/material/colors.dart';
import 'model/event.dart';

void main() {
  runApp(new MaterialApp(
    home: new ToDoList()
  ));
}

class ToDoList extends StatefulWidget {
  @override
  HomePage createState() => new HomePage();
}

class HomePage extends State<ToDoList> {
  String name = "";
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title:new Text("My Tasks"), backgroundColor: Colors.red[400]),
      body: new Container(
        decoration: new BoxDecoration(
                color: Colors.red[50],
              ),
        child: new Column(
          children: <Widget>[
            new TextField(
              decoration: new InputDecoration(
                hintText: "What's your task?"
            ),
            onChanged:(String str){
              setState((){
                name = str;
                Event task1 = new Event(name);
              });
            })
          ],
        ) ,
      )
    );
  }
}


