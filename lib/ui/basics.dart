import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:timato/core/tag_repository.dart';
import 'package:date_format/date_format.dart' as ddlFormat;
import 'package:timato/ui/completed_list.dart';
import 'package:timato/ui/stats_page.dart';

import 'package:time_machine/time_machine.dart';

import 'package:timato/core/event.dart';
import 'package:timato/ui/main_list.dart';
import 'package:timato/ui/today_task_list.dart';

List<Event> todayEventList = [];
List<Event> eventsList = [];
typedef AddEventCallback = void Function(Event context);

///Splits priotity into three levels
enum Priority { HIGH, MIDDLE, LOW, NONE }

class ConstantHelper {
  static List<String> twoLanguageList = ["English", "中文"];

  static Widget repeat(Event task) {
    if (task.repeatProperties == null) {
      return SizedBox();
    } else {
      return Icon(Icons.repeat, color: ConstantHelper.tomatoColor);
    }
  }

  // static List<String> title = [
  //   TimatoLocalization.instance.getTranslatedValue('today'),
  //   TimatoLocalization.instance.getTranslatedValue('yesterday'),
  //   TimatoLocalization.instance.getTranslatedValue('before_yesterday')
  // ];

  // static final Map intToMonth = {
  //   1: TimatoLocalization.instance.getTranslatedValue('month_jan_ab'),
  //   2: TimatoLocalization.instance.getTranslatedValue('month_feb_ab'),
  //   3: TimatoLocalization.instance.getTranslatedValue('month_mar_ab'),
  //   4: TimatoLocalization.instance.getTranslatedValue('month_apr_ab'),
  //   5: TimatoLocalization.instance.getTranslatedValue('month_may_ab'),
  //   6: TimatoLocalization.instance.getTranslatedValue('month_june_ab'),
  //   7: TimatoLocalization.instance.getTranslatedValue('month_july_ab'),
  //   8: TimatoLocalization.instance.getTranslatedValue('month_aug_ab'),
  //   9: TimatoLocalization.instance.getTranslatedValue('month_sept_ab'),
  //   10: TimatoLocalization.instance.getTranslatedValue('month_oct_ab'),
  //   11: TimatoLocalization.instance.getTranslatedValue('month_nov_ab'),
  //   12: TimatoLocalization.instance.getTranslatedValue('month_dec_ab')
  // };

  // static final Map dayOfWeekToRFC = {
  //   DayOfWeek.monday: TimatoLocalization.instance
  //       .getTranslatedValue('weekDayButton_mon_ab'),
  //   DayOfWeek.tuesday:
  //       TimatoLocalization.instance.getTranslatedValue('weekDayButton_t_ab'),
  //   DayOfWeek.wednesday: TimatoLocalization.instance
  //       .getTranslatedValue('weekDayButton_wed_ab'),
  //   DayOfWeek.thursday: TimatoLocalization.instance
  //       .getTranslatedValue('weekDayButton_thur_ab'),
  //   DayOfWeek.friday: TimatoLocalization.instance
  //       .getTranslatedValue('weekDayButton_fri_ab'),
  //   DayOfWeek.saturday: TimatoLocalization.instance
  //       .getTranslatedValue('weekDayButton_sat_ab'),
  //   DayOfWeek.sunday: TimatoLocalization.instance
  //       .getTranslatedValue('weekDayButton_sun_ab'),
  // };

  static final Color tomatoColor = Color.fromRGBO(255, 99, 71, 1);

  //TODO:
  // static BuildContext get context;

  ///Changes the color according to [eventPriority] of [Event]
  static Color priorityColor(AbstractEvent task) {
    if (task.eventPriority == Priority.HIGH) {
      return Color.fromRGBO(202, 45, 45, 1);
    } else if (task.eventPriority == Priority.MIDDLE) {
      return Color.fromRGBO(236, 121, 121, 1);
    } else if (task.eventPriority == Priority.LOW) {
      return Color.fromRGBO(255, 191, 191, 1);
    } else {
      return Colors.white;
    }
  }

  static final Map<String, Priority> priorityEnum = {
    TimatoLocalization.instance.getTranslatedValue('priority_high'):
        Priority.HIGH,
    TimatoLocalization.instance.getTranslatedValue('priority_middle'):
        Priority.MIDDLE,
    TimatoLocalization.instance.getTranslatedValue('priority_low'):
        Priority.LOW,
    TimatoLocalization.instance.getTranslatedValue('priority_none'):
        Priority.NONE
  };

  static final Map<Priority, String> priorityString = {
    Priority.HIGH:
        TimatoLocalization.instance.getTranslatedValue('priority_high'),
    Priority.MIDDLE:
        TimatoLocalization.instance.getTranslatedValue('priority_middle'),
    Priority.LOW:
        TimatoLocalization.instance.getTranslatedValue('priority_low'),
    Priority.NONE:
        TimatoLocalization.instance.getTranslatedValue('priority_none')
  };

  static final Map<Priority, int> priorityLevel = {
    Priority.HIGH: 3,
    Priority.MIDDLE: 2,
    Priority.LOW: 1,
    Priority.NONE: 0
  };

  static final Map<int, String> priorityIntString = {
    3: TimatoLocalization.instance.getTranslatedValue('priority_high'),
    2: TimatoLocalization.instance.getTranslatedValue('priority_middle'),
    1: TimatoLocalization.instance.getTranslatedValue('priority_low'),
    0: TimatoLocalization.instance.getTranslatedValue('priority_none')
  };

  //List for priority level
  static final List<String> priorityList = [
    TimatoLocalization.instance.getTranslatedValue('priority_high'),
    TimatoLocalization.instance.getTranslatedValue('priority_middle'),
    TimatoLocalization.instance.getTranslatedValue('priority_low'),
    TimatoLocalization.instance.getTranslatedValue('priority_none')
  ];

  static Widget tagDdl(Event task) {
    if (task.tag == null && task.ddl == null) {
      return SizedBox();
    } else if (task.tag == null) {
      return new Row(
        children: <Widget>[SizedBox(width: 5), _ddl(task)],
      );
    } else if (task.ddl == null) {
      return new Row(
        children: <Widget>[
          SizedBox(width: 5),
          _tag(task),
        ],
      );
    } else {
      return new Row(
        children: <Widget>[
          SizedBox(width: 5),
          _tag(task),
          SizedBox(
            width: 5,
            height: 1,
          ),
          _ddl(task)
        ],
      );
    }
  }

  static Widget _tag(Event task) {
    if (task.tag != null) {
      return LayoutBuilder(builder: (context, constraints) {
        if (task.tag.length < 10) {
          return Container(
            // width:100,
            child: Text(task.tag,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: TextStyle(color: Colors.black87, fontSize: 12)),
            decoration: BoxDecoration(
              border: new Border.all(color: Colors.red[100]),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            padding: EdgeInsets.all(2),
          );
        } else {
          return Container(
            width: 80,
            child: Text(task.tag,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: TextStyle(color: Colors.black87, fontSize: 12)),
            decoration: BoxDecoration(
              border: new Border.all(color: Colors.red[100]),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            padding: EdgeInsets.all(2),
          );
        }
      });
    } else {
      return SizedBox();
    }
  }

  static Widget _ddl(Event task) {
    if (task.ddl != null) {
      String formatDdl = ddlFormat.formatDate(
          task.ddl, [ddlFormat.yyyy, '-', ddlFormat.mm, '-', ddlFormat.dd]);
      return Container(
        child: Text(formatDdl,
            style: TextStyle(color: Colors.black87, fontSize: 12)),
        decoration: BoxDecoration(
          border: new Border.all(color: Colors.red[100]),
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        padding: EdgeInsets.all(2),
      );
    } else {
      return SizedBox(width: 0.1);
    }
  }
}

class FloatingRaisedButton extends StatelessWidget {
  final void Function() _onPress;
  final String _text;

  FloatingRaisedButton(this._text, this._onPress);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      child: Container(
        child: Text(
          _text,
          style: TextStyle(
            color: ConstantHelper.tomatoColor,
          ),
        ),
        padding: EdgeInsets.only(top: 15, bottom: 15, left: 35, right: 35),
      ),
      onPressed: _onPress,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}

class WarningDialog extends StatelessWidget {
  final String title, text;
  final void Function(BuildContext) action;
  final BuildContext parentContext;

  WarningDialog(this.title, this.text, this.parentContext, this.action);
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: TextStyle(fontSize: 20, color: ConstantHelper.tomatoColor),
        softWrap: true,
        textAlign: TextAlign.left,
      ),
      titlePadding: EdgeInsets.all(20),
      content: Text(text),
      actions: <Widget>[
        FlatButton(
          child: Text(
            TimatoLocalization.instance.getTranslatedValue('cancel'),
            style: TextStyle(color: Colors.black38),
          ),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
        FlatButton(
          child: Text(
            TimatoLocalization.instance.getTranslatedValue('confirm'),
            style: TextStyle(color: ConstantHelper.tomatoColor),
          ),
          onPressed: () {
            action(parentContext);
            Navigator.pop(context, true);
          },
        ),
      ],
    );
  }

  static show(
      {@required String title,
      @required String text,
      @required BuildContext context,
      @required void Function(BuildContext) action}) {
    return showDialog(
        context: context,
        builder: (_) => WarningDialog(title, text, context, action),
        barrierDismissible: true);
  }
}

class SideBar extends StatelessWidget {
  SideBar(this.pageName);
  final String pageName;

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(children: <Widget>[
      DrawerHeader(
          child: Text(
            TimatoLocalization.instance.getTranslatedValue('slogan'),
            style: TextStyle(fontSize: 16),
          ),
          decoration: BoxDecoration(color: ConstantHelper.tomatoColor)),
      ListTile(
          title: Text(
              TimatoLocalization.instance.getTranslatedValue('main_page'),
              style: TextStyle(fontSize: 16)),
          onTap: () {
            if (pageName == 'MyTask') {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) {
                return MyTask();
              }));
            }
          }),
      ListTile(
          title: Text(
              TimatoLocalization.instance.getTranslatedValue('today_page'),
              style: TextStyle(fontSize: 16)),
          onTap: () {
            if (pageName == 'TodayList') {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) {
                return TodayList();
              }));
            }
          }),
      ListTile(
          title: Text(
              TimatoLocalization.instance.getTranslatedValue('completed_page'),
              style: TextStyle(fontSize: 16)),
          onTap: () {
            if (pageName == 'Completed') {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) {
                return CompletedList();
              }));
            }
          }),
      ListTile(
          title: Text(
              TimatoLocalization.instance.getTranslatedValue('my_stats'),
              style: TextStyle(fontSize: 16)),
          onTap: () async {
            var weekDayTimerNums = await getWeekTimerNum();
            var timerNumsToday = await getTodayTimerNum();
            var timerNumsWeek = weekDayTimerNums.fold(
                0, (previousValue, element) => previousValue + element);
            var tagTimerNumsToday = await getTodayTagTimerNum();
            var tagTimerNumsWeek = await getWeekTagTimerNum();

            Navigator.push(context, MaterialPageRoute(builder: (_) {
              return StatsPage(
                timerNumsWeek: timerNumsWeek,
                tagTimerNumsToday: tagTimerNumsToday,
                timerNumsToday: timerNumsToday,
                tagTimerNumsWeek: tagTimerNumsWeek,
                weekDayTimerNums: weekDayTimerNums,
              );
            }));
          }),
      ListTile(
          subtitle: Text(
              TimatoLocalization.instance.getTranslatedValue('version'),
              style: TextStyle(fontSize: 12, color: Colors.grey)))
    ]));
  }
}

class TimerLengthAlert extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        TimatoLocalization.instance.getTranslatedValue('invalid_input'),
        style: TextStyle(fontSize: 14),
        softWrap: true,
        textAlign: TextAlign.left,
      ),
      titlePadding: EdgeInsets.all(10),
      content: Text(
          TimatoLocalization.instance.getTranslatedValue('value_restriction')),
      actions: <Widget>[
        FlatButton(
          child: Text(
            TimatoLocalization.instance.getTranslatedValue('ok'),
            style: TextStyle(color: Colors.lightBlue),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
    );
  }

  static show(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) => TimerLengthAlert(),
        barrierDismissible: true);
  }
}

int getWeekNum(LocalDate date) {
  LocalDate firstDay = LocalDate(date.year, date.monthOfYear, 1);
  LocalDate lastDay =
      LocalDate(date.year, date.monthOfYear + 1, 1).subtractDays(1);
  int firstSunday = 1 + (7 - firstDay.dayOfWeek.value);
  int lastMonday = 31 - lastDay.dayOfWeek.value + 1;
  if (date.dayOfMonth <= firstSunday) {
    return 1;
  } else if (date.dayOfMonth <= firstSunday + 7) {
    return 2;
  } else if (date.dayOfMonth <= firstSunday + 14) {
    return 3;
  } else if (date.dayOfMonth <= firstSunday + 21) {
    if (date.dayOfMonth >= lastMonday) {
      return -1;
    } else {
      return 4;
    }
  } else {
    return -1;
  }
}

extension Conversion on DateTime {
  LocalDateTime toLocalDateTime() {
    return LocalDateTime(this.year, this.month, this.day, 0, 0, 0);
  }
}

class Language {
  final int id;
  final String name;
  final String languageCode;

  Language(this.id, this.name, this.languageCode);

  static final Map<Language, String> languageString = {
    Language(1, 'English', 'en'): 'English',
    Language(2, '中文', 'zh'): '中文',
  };

  static final Map<Locale, String> localeString = {
    Locale('en', ''): 'English',
    Locale('zh', ''): '中文',
  };

  static final Map<String, Language> stringlanguage = {
    'English': Language(1, 'English', 'en'),
    '中文': Language(2, '中文', 'zh'),
  };

  static List<Language> languageList() {
    return <Language>[
      Language(1, 'English', 'en'),
      Language(2, '中文', 'zh'),
    ];
  }
}

class TimatoLocalization {
  TimatoLocalization(this.locale);

  static TimatoLocalization instance;

  Map<String, String> _localizedValues;
  Locale locale;

  Future load() async {
    String jsonStringValues =
        await rootBundle.loadString("lib/language/${locale.languageCode}.json");

    Map<String, dynamic> mappedJson = json.decode(jsonStringValues);

    _localizedValues =
        mappedJson.map((key, value) => MapEntry(key, value.toString()));

    TimatoLocalization.instance = this;
  }

  Future<Locale> setLocale(String languageCode) async {
    this.locale = Locale(languageCode, "");
    await load();

    return this.locale;
  }

  String getTranslatedValue(String key) {
    return _localizedValues[key];
  }

  static const LocalizationsDelegate<TimatoLocalization> delegate =
      _TimatoLocalizationDelegate();
}

class _TimatoLocalizationDelegate
    extends LocalizationsDelegate<TimatoLocalization> {
  const _TimatoLocalizationDelegate();
  @override
  bool isSupported(Locale locale) {
    return true;
  }

  @override
  Future<TimatoLocalization> load(Locale locale) async {
    TimatoLocalization localization = new TimatoLocalization(locale);
    await localization.load();
    return localization;
  }

  @override
  bool shouldReload(_TimatoLocalizationDelegate old) => false;
}
