import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:timato/core/notifications.dart';
import 'package:timato/ui/timato_timer_widget.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  notificationInit();
  await initPreferences();

  var timerData = await getTimerData();
  runApp(MyApp(timerData[0], timerData[1]));

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarDividerColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
}

initPreferences() async{
  SharedPreferences pref = await SharedPreferences.getInstance();
  if (pref.get("firstLaunch") == null){
    pref.setBool("firstLaunch", true);
    pref.setInt("timerLength", 25*60);
    pref.setInt("relaxLength", 5*60);
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final timerLength;
  final relaxLength;
  MyApp(this.timerLength, this.relaxLength);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: TimatoTimerWidget(timerLength, relaxLength),
    );
  }
}