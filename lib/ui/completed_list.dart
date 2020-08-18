import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:timato/core/completed_repository.dart';
import 'package:timato/core/db.dart';
import 'package:timato/core/event.dart';
import 'package:timato/core/event_repository.dart';
import 'package:timato/ui/add_event.dart';
import 'package:timato/ui/basics.dart';

// List<String> title = [TimatoLocalization.instance.getTranslatedValue('today'), TimatoLocalization.instance.getTranslatedValue('yesterday'), TimatoLocalization.instance.getTranslatedValue('before_yesterday')];
Map<Key, Function> refreshFunc = Map<Key, Function>();

// List<String> title = [
//     TimatoLocalization.instance.getTranslatedValue("today"),
//     TimatoLocalization.instance.getTranslatedValue("yesterday"),
//     TimatoLocalization.instance.getTranslatedValue("before_yesterday")
//   ];

class CompletedList extends StatefulWidget {
  _CompletedListState _state;
  @override
  _CompletedListState createState() {
    _state = new _CompletedListState();
    return _state;
  }

  void refreshState() {
    if (_state == null || !_state.mounted) return;
    _state.setState(() {});
  }
}

class _CompletedListState extends State<CompletedList> {
  DatabaseHelper tabaseHelper = DatabaseHelper();

  @override
  void setState(VoidCallback fn) {
    if (this == null || !mounted) return;
    refreshFunc.forEach((key, value) {
      value();
    });
    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
          elevation: 0,
          iconTheme: new IconThemeData(color: ConstantHelper.tomatoColor),
          title: new Text(TimatoLocalization.instance.getTranslatedValue('completed_page'),
              style: TextStyle(color: ConstantHelper.tomatoColor)),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.delete, color: ConstantHelper.tomatoColor),
                onPressed: () async {
                  var data = WarningDialog.show(
                      title: TimatoLocalization.instance.getTranslatedValue('empty_list_title'),
                      text: TimatoLocalization.instance.getTranslatedValue('empty_list'),
                      context: context,
                      action: (context) async {
                        await deleteAllCompleted();
                        setState(() {});
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
  List<String> title = [
    TimatoLocalization.instance.getTranslatedValue("today"),
    TimatoLocalization.instance.getTranslatedValue("yesterday"),
    TimatoLocalization.instance.getTranslatedValue("before_yesterday")
  ];
  return ListView.builder(
    itemCount: 3,
    itemBuilder: (BuildContext context, int i) {
      print('here'+title[i]);
      return new DateTile(date: title[i]);
    },
  );
}

class DateTile extends StatefulWidget {
  DateTile({Key key, this.date}) : super(key: key);
  String date;
  @override
  _DateTileState createState() => _DateTileState(date);
}

class _DateTileState extends State<DateTile> {
  _DateTileState(this.date);
  String date;
  List<Event> completed = [];
  Key _key = UniqueKey();

  int findLength(List<Event> completed) {
    if (completed == null) {
      return 0;
    } else {
      return completed.length;
    }
  }

  @override
  void initState() {
    refreshFunc[_key] = this.refreshState;
    refreshState();
  }

  @override
  void dispose() {
    super.dispose();
    refreshFunc.remove(this._key);
  }

  void refreshState() {
    findCompleted(date);
  }

  Future<void> findCompleted(String date) async {
    if (date == TimatoLocalization.instance.getTranslatedValue('today')) {
      completed = await getTodayCompletedList();
    } else if (date == TimatoLocalization.instance.getTranslatedValue('yesterday')) {
      completed = await getYesterdayCompletedList();
    } else {
      completed = await getBeforeYesterdayCompletedList();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        secondaryActions: <Widget>[
          IconSlideAction(
              color: ConstantHelper.tomatoColor,
              iconWidget: IconButton(
                icon: Icon(Icons.delete, color: Colors.white),
                onPressed: () async {
                  if (date == TimatoLocalization.instance.getTranslatedValue('today')) {
                    print("got here today");
                    WarningDialog.show(
                        title: TimatoLocalization.instance.getTranslatedValue('empty_today_list_title'),
                        text:
                            TimatoLocalization.instance.getTranslatedValue('empty_today_list'),
                        context: context,
                        action: (context) async {
                          await deleteToday();
                          context
                              .findAncestorWidgetOfExactType<CompletedList>()
                              .refreshState();
                        });
                  } else if (date == TimatoLocalization.instance.getTranslatedValue('yesterday')) {
                    var data = WarningDialog.show(
                        title: TimatoLocalization.instance.getTranslatedValue('empty_yesterday_list_title'),
                        text:
                            TimatoLocalization.instance.getTranslatedValue('empty_yesterday_list'),
                        context: context,
                        action: (context) async {
                          await deleteYesterday();
                          context
                              .findAncestorWidgetOfExactType<CompletedList>()
                              .refreshState();
                        });
                  } else {
                    print(TimatoLocalization.instance.getTranslatedValue('today'));
                    print(date);
                    var data = WarningDialog.show(
                        title: TimatoLocalization.instance.getTranslatedValue('empty_before_list_title'),
                        text:
                            TimatoLocalization.instance.getTranslatedValue('empty_before_list'),
                        context: context,
                        action: (context) async {
                          await deleteBeforeYesterday();
                          context
                              .findAncestorWidgetOfExactType<CompletedList>()
                              .refreshState();
                        });
                  }
                },
              )),
        ],
        child: ExpansionTile(
          title: Container(
              child: new Row(children: <Widget>[
            Icon(
              Icons.fiber_manual_record,
              color: ConstantHelper.tomatoColor,
              size: 10,
            ),
            SizedBox(width: 8),
            Text(date,
                style: TextStyle(
                  fontSize: 17,
                  color: ConstantHelper.tomatoColor,
                ))
          ])),
          onExpansionChanged: (value) {},
          children: <Widget>[
            Container(
                height: (35.0 * findLength(completed)),
                child: ListView(
                    // key:task
                    physics: new NeverScrollableScrollPhysics(),
                    children: completed.map((completedTask) {
                      return Container(
                          height: 35,
                          child: new Row(children: <Widget>[
                            SizedBox(width: 25),
                            Icon(
                              Icons.fiber_manual_record,
                              color: Colors.red[100],
                              size: 10,
                            ),
                            SizedBox(width: 5),
                            Text(completedTask.taskName,
                                style: TextStyle(fontSize: 15))
                          ]));
                    }).toList()))
          ],
        ));
  }
}