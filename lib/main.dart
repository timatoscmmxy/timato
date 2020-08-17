import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:path/path.dart';

import 'package:sqflite/sqflite.dart';

import 'package:timato/core/notifications.dart';
import 'package:timato/ui/add_event.dart';
import 'package:timato/ui/basics.dart';
import 'package:timato/ui/settings_widget.dart';
import 'package:timato/ui/stats_page.dart';
import 'package:timato/ui/timato_timer_widget.dart';
import 'package:timato/ui/main_list.dart';
import 'package:timato/ui/event_detail_page.dart';
import 'package:timato/core/event.dart';
import 'package:timato/ui/today_task_list.dart';
import 'package:timato/ui/basics.dart';

import 'core/event_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  notificationInit();
  getEventList().then((data) {
    eventsList = data;
  });
  await initPreferences();
  await initTodaylist();
  await _updateDdl();

  SharedPreferences pref =
                      await SharedPreferences.getInstance();
  String language = pref.getString('language') ?? 'zh';
  Locale locale = Locale(language, '');

  // Locale _locale;

  runApp(MaterialApp(
    supportedLocales: [
      const Locale('en', ''),
      const Locale('zh', ''),
    ],
    locale: locale,
    localizationsDelegates: [
      TimatoLocalization.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    localeResolutionCallback: (deviceLocale, supportedLocales){
      for(var locale in supportedLocales) {
        if(locale.languageCode == deviceLocale.languageCode){
          return deviceLocale;
        }
      }
      return supportedLocales.first;
    },
    home: TodayList(),
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.white,
      scaffoldBackgroundColor: Colors.white,
      accentColor: ConstantHelper.tomatoColor,
    ),
  ));

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

initPreferences() async {
  const DEFAULT_TIMER_LENGTH = 25 * 60;
  const DEFAULT_RELAX_LENGTH = 5 * 60;

  final SharedPreferences pref = await SharedPreferences.getInstance();

  if (pref.get("firstLaunch") == null) {
    pref.setBool("firstLaunch", true);
    pref.setInt("timerLength", DEFAULT_TIMER_LENGTH);
    pref.setInt("relaxLength", DEFAULT_RELAX_LENGTH);
    pref.setString("lastLogin", dateOnly(DateTime.now()).toString());
  }
}

initTodaylist() async {
  final SharedPreferences pref = await SharedPreferences.getInstance();

  DateTime lastLogin = DateTime.parse(pref.getString("lastLogin"));
  DateTime today = dateOnly(DateTime.now());
  if (today.isAfter(lastLogin)) {
    getTodayEventList().then((data) {
      todayEventList = data;
    });
    for (int i = 0; i < todayEventList.length; i++) {
      todayEventList[i].isTodayList = 0;
      updateEvent(todayEventList[i]);
    }
  }
  pref.setString("lastLogin", today.toString());
}

_updateDdl() {
  for (int i = 0; i < eventsList.length; i++) {
    if (eventsList[i].repeatProperties != null) {
      eventsList[i].ddl =
          eventsList[i].repeatProperties.nextOccurrence().toDateTimeLocal();
      updateEvent(eventsList[i]);
    }
  }
}