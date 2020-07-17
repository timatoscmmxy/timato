import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/material/colors.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:timato/core/event.dart';
import 'package:timato/ui/basics.dart';
import 'package:timato/core/db.dart';
import 'package:timato/ui/event_list.dart';
import 'dart:developer' as developer;

class MyApp3 extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TodayList(),
    );
  }
}

class TodayList extends StatefulWidget {
  @override
  _TodayListState createState() => _TodayListState();
}

class _TodayListState extends State<TodayList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(),
    );
  }
}