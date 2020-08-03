import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:timato/core/event.dart';
import 'package:timato/core/event_repository.dart';
import 'package:timato/ui/add_event.dart';
import 'package:timato/ui/basics.dart';

class CompletedList extends StatefulWidget {
  @override
  _CompletedListState createState() => _CompletedListState();
}

class _CompletedListState extends State<CompletedList> {
  EventRepository databaseHelper = EventRepository();

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
                  //TODO: empty the entire table
                  setState((){});
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
  return ListView(
    children: <Widget>[
      //TODO: overflowed by 8px when height was 50
      Container(
          height: 58, color: Colors.white, child: DateTile(date: "Today")),
      Container(
          height: 58, color: Colors.white, child: DateTile(date: "Yesterday")),
      Container(
          height: 58,
          color: Colors.white,
          child: DateTile(date: "Before Yesterday")),
    ],
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

  @override
  Widget build(BuildContext context) {
    List<Event> completed;
    if (date == "Today") {
      completed = [];
    } else if (date == "Yesterday") {
      completed = [];
    } else {
      completed = [];
    }
    return Slidable(
        // key: task.key,
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        secondaryActions: <Widget>[
          IconSlideAction(
              color: ConstantHelper.tomatoColor,
              iconWidget: IconButton(
                icon: Icon(Icons.delete, color: Colors.white),
                onPressed: () {
                  if (date == "Today") {
                    //TODO: delete all the events that are marked as "today's completed" on the completed table
                  } else if (date == "Yesterday") {
                    //TODO: delete all the events that are marked as "yesterday's completed" on the completed table
                  } else {
                    //TODO: delete all the events that are marked as "before yesterday's completed" on the completed table
                  }
                  setState(() {
                    completed = [];
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
          children: <Widget>[
            Container(
                height: (50.0 * completed.length),
                child: ListView(
                    children: completed.map((completedTask) {
                  _completedTask(completedTask);
                }).toList()))
          ],
        ));
  }
}

Widget _completedTask(Event completedTask) {
  return Container(
      height: 45,
      child: new Row(children: <Widget>[
        SizedBox(width: 15),
        Text(completedTask.taskName, style: TextStyle(fontSize: 12))
      ]));
}
