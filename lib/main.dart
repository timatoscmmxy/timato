import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:path/path.dart';

import 'package:sqflite/sqflite.dart';

import 'package:timato/core/notifications.dart';
import 'package:timato/ui/basics.dart';
import 'package:timato/ui/settings_widget.dart';
import 'package:timato/ui/timato_timer_widget.dart';
import 'package:timato/ui/main_list.dart';
import 'package:timato/ui/event_list.dart';
import 'package:timato/core/event.dart';
import 'package:timato/ui/today_task_list.dart';

import 'core/event_repository.dart';

void main() async{
  runApp(MaterialApp(
      home: MyTask()
    ));

  EventRepository databaseHelper = EventRepository();
  databaseHelper
      .insertEvent(Event(
      taskName: '背单词1', eventPriority: Priority.HIGH, tag: 'English'));
  databaseHelper
      .insertEvent(Event(
      taskName: '背单词2', eventPriority: Priority.LOW, tag: 'Chinese'));
  databaseHelper
      .insertEvent(Event(
      taskName: '背单词3', eventPriority: Priority.MIDDLE, tag: 'English'));
}
//void main() => runApp(MyApp1());

// void main() async{
//   WidgetsFlutterBinding.ensureInitialized();
//   notificationInit();
//   await initPreferences();

//   var timerData = await getTimerData();
//   var pref = await SharedPreferences.getInstance();
//   runApp(MyApp(pref));

//   SystemChrome.setSystemUIOverlayStyle(
//     const SystemUiOverlayStyle(
//       statusBarColor: Colors.white,
//       statusBarBrightness: Brightness.dark,
//       statusBarIconBrightness: Brightness.dark,
//       systemNavigationBarColor: Colors.white,
//       systemNavigationBarDividerColor: Colors.black,
//       systemNavigationBarIconBrightness: Brightness.dark,
//     ),
//   );
// }

// initPreferences() async{
//   const DEFAULT_TIMER_LENGTH = 25*60;
//   const DEFAULT_RELAX_LENGTH = 5*60;

//   final SharedPreferences pref = await SharedPreferences.getInstance();

//   if (pref.get("firstLaunch") == null){
//     pref.setBool("firstLaunch", true);
//     pref.setInt("timerLength", DEFAULT_TIMER_LENGTH);
//     pref.setInt("relaxLength", DEFAULT_RELAX_LENGTH);
//   }
// }

// class MyApp extends StatelessWidget {
//   // This widget is the root of your application.
// //  final timerLength;
// //  final relaxLength;
//   final _pref;
//   MyApp(this._pref);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         brightness: Brightness.light,
//         primaryColor: Colors.white,
//         scaffoldBackgroundColor: Colors.white,
//       ),
//       home: TimatoTimerWidget(
//         event: Event(taskName: '写timato_timer_widget.dart'),
//         timerLength: 10,
//         relaxLength: 10,
//       ),
// //      home: Settings(_pref)
//     );
//   }
// }
