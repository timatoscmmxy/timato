import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:rrule/rrule.dart';
import 'package:timato/core/event_repository.dart';

import 'package:time_machine/time_machine.dart';

import 'package:timato/core/event.dart';
import 'package:timato/ui/basics.dart';

DateTime dateOnly(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

String formatDate(dynamic date) {
  if (date is DateTime) {
    return '${ConstantHelper.intToMonth[date.month]} ${date.day}';
  } else if (date is LocalDate) {
    return '${ConstantHelper.intToMonth[date.monthOfYear]} ${date.dayOfMonth}';
  } else if (date is LocalDateTime) {
    return '${ConstantHelper.intToMonth[date.monthOfYear]} ${date.dayOfMonth}';
  } else {
    return null;
  }
}

class AddEvent extends StatefulWidget {
  final String _textHint;
  final bool isPlanned;

  AddEvent(this._textHint, {this.isPlanned});

  @override
  AddEventState createState() => AddEventState();

  static showAddEvent(context) async{
    AbstractEvent newEvent = await showModalBottomSheet(
      context: context,
      builder: (_) => AddEvent(
        'New event',
        isPlanned: false,
      ),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15.0))),
    );
    newEvent.taskOrder = eventsList.length;
    await insertEvent(newEvent);
  }

  static showAddUnplannedEvent(context) async{
    AbstractEvent newEvent = await showModalBottomSheet(
      context: context,
      builder: (_) => AddEvent(
        'New unplanned event',
        isPlanned: true,
      ),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15.0))),
    );
    newEvent.taskOrder = eventsList.length;
    newEvent.todayOrder = todayEventList.length;
    await insertEvent(newEvent);
  }
}

// ignore: must_be_immutable
class AddEventState extends State<AddEvent> {
  Event newEvent;
  Icon calendarIcon;
  FlatButton doneButton;

  @override
  void initState() {
    super.initState();
    newEvent = Event(taskName: "new event");
    calendarIcon = Icon(
      Icons.calendar_today,
      color: ConstantHelper.tomatoColor,
    );
    doneButton = FlatButton(
      child:
          Text('Done', style: TextStyle(color: Colors.black26, fontSize: 18)),
      onPressed: null,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(10.0))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
          ),
          Padding(
            padding: EdgeInsets.all(0),
            child: Container(
              child: TextField(
                decoration: InputDecoration(
                  hintText: widget._textHint,
                ),
                autofocus: true,
                maxLines: null,
                onChanged: (string) {
                  newEvent.taskName = string;
                  if (string == "") {
                    setState(() {
                      doneButton = FlatButton(
                        child: Text('Done',
                            style:
                                TextStyle(color: Colors.black26, fontSize: 18)),
                        onPressed: null,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(10.0))),
                      );
                    });
                  } else {
                    setState(() {
                      doneButton = FlatButton(
                        child: Text('Done',
                            style: TextStyle(
                                color: ConstantHelper.tomatoColor,
                                fontSize: 18)),
                        onPressed: () {
                          Navigator.pop(context, newEvent);
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(10.0))),
                      );
                    });
                  }
                },
              ),
              padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 30),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(5),
                  child: IconButton(
                    icon: calendarIcon,
                    onPressed: () async {
                      newEvent.ddl =
                          await DateTimeSelector.show(context, newEvent.ddl) ??
                              newEvent.ddl;
                      setState(() {
                        if (newEvent.ddl != null) {
                          calendarIcon = Icon(
                            Icons.event_available,
                            color: ConstantHelper.tomatoColor,
                          );
                        }
                      });
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                  child: IconButton(
                    icon: Icon(
                      Icons.timer,
                      color: ConstantHelper.tomatoColor,
                    ),
                    onPressed: () async {
                      newEvent.duration = await SetDuration.show(context);
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                  child: IconButton(
                    icon: Icon(
                      Icons.info_outline,
                      color: ConstantHelper.tomatoColor,
                    ),
                    onPressed: () async {
                      newEvent.tag = await SetTag.show(context);
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                  child: IconButton(
                    icon: Icon(
                      Icons.low_priority,
                      color: ConstantHelper.tomatoColor,
                    ),
                    onPressed: () async {
                      newEvent.eventPriority = await SetPriority.show(
                              context, newEvent.eventPriority) ??
                          newEvent.eventPriority;
                    },
                  ),
                ),
                Expanded(
                  child: Container(),
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                  child: doneButton,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(),
          )
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class DateTimeSelector extends StatelessWidget {
  DateTime dateSelected;

  DateTimeSelector({DateTime selected})
      : this.dateSelected = selected ?? dateOnly(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CalendarDatePicker(
            lastDate: DateTime(9999, 12, 31),
            initialDate: dateSelected,
            firstDate: dateOnly(DateTime.now()),
            onDateChanged: (DateTime date) => dateSelected = date,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
          ),
          Container(
            child: ListTile(
              leading: Icon(Icons.repeat),
              title: Text('Repeat'),
              onTap: () {
                Navigator.pop(context);
                SetRepeatProperties.show(context, dateSelected);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                child: Container(),
              ),
              Container(
                child: FlatButton(
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.black38,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context, null);
                  },
                ),
              ),
              Container(
                child: FlatButton(
                  child: Text(
                    'OK',
                    style: TextStyle(
                      color: ConstantHelper.tomatoColor,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context, dateSelected);
                  },
                ),
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(),
          )
        ],
      ),
    ));
  }

  static show(context, DateTime date) async {
    DateTime dateSelected;
    dateSelected = await showDialog<DateTime>(
        context: context,
        builder: (_) => DateTimeSelector(
              selected: date,
            ),
        barrierDismissible: true);
    return dateSelected;
  }
}

class SetTag extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String tag;
    return AlertDialog(
      content: Container(
        child: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Give your event an tag",
          ),
          onChanged: (s) => tag = s,
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text(
            'Cancel',
            style: TextStyle(color: Colors.black38),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        FlatButton(
          child: Text(
            'Confirm',
            style: TextStyle(color: ConstantHelper.tomatoColor),
          ),
          onPressed: () {
            Navigator.pop(context, tag);
          },
        ),
      ],
    );
  }

  static show(context) async {
    return await showDialog(
        context: context, builder: (_) => SetTag(), barrierDismissible: true);
  }
}

class SetDuration extends StatefulWidget {
  static show(context) async {
    return await showDialog(
        context: context,
        builder: (_) => SetDuration(),
        barrierDismissible: true);
  }

  @override
  State<StatefulWidget> createState() => _SetDurationState();
}

class _SetDurationState extends State<SetDuration> {
  FlatButton confirmButton;
  TextEditingController controller;

  int duration;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    confirmButton = FlatButton(
      child: Text(
        'Confirm',
        style: TextStyle(color: Colors.black38),
      ),
      onPressed: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        child: TextField(
          autofocus: true,
          controller: controller,
          inputFormatters: [
            WhitelistingTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(18),
          ],
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: "Expected time taken (in minutes)",
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
          ),
          onChanged: (s) {
            if (s == '0' || s == '') {
              controller.text = '';
              setState(() {
                confirmButton = FlatButton(
                  child: Text(
                    'Confirm',
                    style: TextStyle(color: Colors.black38),
                  ),
                  onPressed: null,
                );
              });
            } else {
              duration = int.parse(s);
              setState(() {
                confirmButton = FlatButton(
                  child: Text(
                    'Confirm',
                    style: TextStyle(color: ConstantHelper.tomatoColor),
                  ),
                  onPressed: () => Navigator.pop(context, duration),
                );
              });
            }
          },
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text(
            'Cancel',
            style: TextStyle(color: Colors.black38),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        confirmButton
      ],
    );
  }
}

class SetPriority extends StatefulWidget {
  final originPriority;

  SetPriority(this.originPriority);

  static show(context, Priority priority) async {
    return await showDialog(
        context: context,
        builder: (_) => SetPriority(priority),
        barrierDismissible: true);
  }

  @override
  State<StatefulWidget> createState() => _SetPriorityState();
}

class _SetPriorityState extends State<SetPriority> {
  Priority priority;

  @override
  void initState() {
    super.initState();
    priority = widget.originPriority;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Choosing event priority',
        style: TextStyle(fontSize: 20, color: ConstantHelper.tomatoColor),
        softWrap: true,
        textAlign: TextAlign.left,
      ),
      content: DropdownButton<Priority>(
        onChanged: (value) {
          setState(() {
            priority = value;
          });
        },
        items: [
          DropdownMenuItem<Priority>(
            value: Priority.HIGH,
            child: Text('High'),
          ),
          DropdownMenuItem<Priority>(
            value: Priority.MIDDLE,
            child: Text('Middle'),
          ),
          DropdownMenuItem<Priority>(
            value: Priority.LOW,
            child: Text('Low'),
          ),
          DropdownMenuItem<Priority>(
            value: Priority.NONE,
            child: Text('None'),
          )
        ],
        value: priority,
      ),
      actions: <Widget>[
        FlatButton(
          child: Text(
            'Cancel',
            style: TextStyle(color: Colors.black38),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        FlatButton(
          child: Text(
            'Confirm',
            style: TextStyle(color: ConstantHelper.tomatoColor),
          ),
          onPressed: () {
            Navigator.pop(context, priority);
          },
        ),
      ],
    );
  }
}

class SetRepeatProperties extends StatefulWidget {
  final DateTime startDate;

  SetRepeatProperties(this.startDate);

  static show(context, DateTime startDate) async {
    return await showDialog(
        context: context,
        builder: (_) => SetRepeatProperties(startDate),
        barrierDismissible: true);
  }

  @override
  State<StatefulWidget> createState() => _SetRepeatPropertiesState();
}

class _SetRepeatPropertiesState extends State<SetRepeatProperties> {
  bool byWeekdaysInMonth;
  DateTime start;
  Frequency frequency;
  int interval;
  ByWeekDayEntry weekDay;
  Set<ByWeekDayEntry> byWeekDays;
  int monthDay;
  int week;
  int month;
  RecurrenceRule rule;

  TextEditingController intervalController;
  TextEditingController startController;

  RecurrenceRule toRecurrenceRule() {
    if (frequency == Frequency.daily) {
      return RecurrenceRule(
          frequency: frequency,
          interval: interval,
          weekStart: DayOfWeek.monday);
    } else if (frequency == Frequency.weekly) {
      return RecurrenceRule(
          frequency: frequency,
          interval: interval,
          byWeekDays: byWeekDays,
          weekStart: DayOfWeek.monday);
    } else if (frequency == Frequency.monthly) {
      if (byWeekdaysInMonth) {
//        return RecurrenceRule(
//            frequency: frequency,
//            interval: interval,
//            byWeeks: {week},
//            byWeekDays: {weekDay});
        return RecurrenceRule.fromString(
            'RRULE:FREQ=MONTHLY;INTERVAL=$interval;BYDAY=$week${ConstantHelper.dayOfWeekToRFC[weekDay.day]};WKST=MO');
      } else {
        return RecurrenceRule(
            frequency: frequency,
            interval: interval,
            byMonthDays: {monthDay},
            weekStart: DayOfWeek.monday);
      }
    } else if (frequency == Frequency.yearly) {
      return RecurrenceRule(
          frequency: frequency,
          interval: interval,
          weekStart: DayOfWeek.monday);
    } else {
      return null;
    }
  }

  Widget weekDayButton(String text, ByWeekDayEntry value) {
    bool selected;
    Color backgroundColor;
    Color textColor;
    if (byWeekDays.contains(value)) {
      selected = true;
      backgroundColor = ConstantHelper.tomatoColor;
      textColor = Colors.white;
    } else {
      selected = false;
      backgroundColor = Colors.white;
      textColor = Colors.black;
    }
    return Padding(
      padding: EdgeInsets.only(left: 6, right: 6),
      child: Container(
        height: 30,
        width: 30,
        child: FloatingActionButton(
          backgroundColor: backgroundColor,
          child: Text(
            text,
            style: TextStyle(color: textColor),
          ),
          onPressed: () {
            setState(() {
              if (selected == true) {
                byWeekDays.remove(value);
              } else {
                byWeekDays.add(value);
              }
            });
          },
        ),
      ),
    );
  }

  List<DropdownMenuItem> getMonthDays() {
    List<DropdownMenuItem> result = [];
    for (int i = 1; i < 32; ++i) {
      result.add(DropdownMenuItem(
        value: i,
        child: Padding(
          child: Text('Day $i'),
          padding: EdgeInsets.all(5),
        ),
      ));
    }
    result.add(DropdownMenuItem(
      value: -1,
      child: Padding(
        child: Text('Last Day'),
        padding: EdgeInsets.all(5),
      ),
    ));
    return result;
  }

  Widget monthWeekSelection() {
    if (frequency == Frequency.weekly) {
      return Container(
          padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                weekDayButton('M', ByWeekDayEntry(DayOfWeek.monday)),
                weekDayButton('T', ByWeekDayEntry(DayOfWeek.tuesday)),
                weekDayButton('W', ByWeekDayEntry(DayOfWeek.wednesday)),
                weekDayButton('T', ByWeekDayEntry(DayOfWeek.thursday)),
                weekDayButton('F', ByWeekDayEntry(DayOfWeek.friday)),
                weekDayButton('S', ByWeekDayEntry(DayOfWeek.saturday)),
                weekDayButton('S', ByWeekDayEntry(DayOfWeek.sunday)),
              ],
            ),
          ));
    } else if (frequency == Frequency.monthly) {
      return Container(
        child: Column(
          children: <Widget>[
            ListTile(
                leading: Radio(
                  value: false,
                  groupValue: byWeekdaysInMonth,
                  onChanged: (value) {
                    setState(() {
                      byWeekdaysInMonth = value;
                    });
                  },
                ),
                title: Container(
                  color: Colors.black12,
                  child: DropdownButton(
                    isExpanded: true,
                    value: monthDay,
                    items: getMonthDays(),
                    onChanged: (value) {
                      setState(() {
                        monthDay = value;
                      });
                    },
                  ),
                )),
            ListTile(
              leading: Radio(
                value: true,
                groupValue: byWeekdaysInMonth,
                onChanged: (value) {
                  setState(() {
                    byWeekdaysInMonth = value;
                  });
                },
              ),
              title: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      color: Colors.black12,
                      child: DropdownButton(
                        isExpanded: true,
                        value: week,
                        items: <DropdownMenuItem>[
                          DropdownMenuItem(
                            value: 1,
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Text('First'),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 2,
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Text('Second'),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 3,
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Text('Third'),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 4,
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Text('Fourth'),
                            ),
                          ),
                          DropdownMenuItem(
                            value: -1,
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Text('Last'),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            week = value;
                          });
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.black12,
                      child: DropdownButton(
                        isExpanded: true,
                        value: weekDay,
                        items: <DropdownMenuItem>[
                          DropdownMenuItem(
                            value: ByWeekDayEntry(DayOfWeek.monday),
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Text('Mon'),
                            ),
                          ),
                          DropdownMenuItem(
                            value: ByWeekDayEntry(DayOfWeek.tuesday),
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Text('Tue'),
                            ),
                          ),
                          DropdownMenuItem(
                            value: ByWeekDayEntry(DayOfWeek.wednesday),
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Text('Wed'),
                            ),
                          ),
                          DropdownMenuItem(
                            value: ByWeekDayEntry(DayOfWeek.thursday),
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Text('Thu'),
                            ),
                          ),
                          DropdownMenuItem(
                            value: ByWeekDayEntry(DayOfWeek.friday),
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Text('Fri'),
                            ),
                          ),
                          DropdownMenuItem(
                            value: ByWeekDayEntry(DayOfWeek.saturday),
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Text('Sat'),
                            ),
                          ),
                          DropdownMenuItem(
                            value: ByWeekDayEntry(DayOfWeek.sunday),
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Text('Sun'),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            weekDay = value;
                          });
                        },
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  Widget startSelection() {
    if (frequency == Frequency.daily) {
      return Container(
        child: Row(
          children: <Widget>[
            Padding(
              child: Text('Start'),
              padding: EdgeInsets.only(right: 5),
            ),
            Expanded(
              child: Container(
                  child: FlatButton(
                child: Align(
                  child: Text(
                    formatDate(start),
                    textAlign: TextAlign.left,
                  ),
                  alignment: Alignment.centerLeft,
                ),
                onPressed: () async {
                  DateTime date = await showDatePicker(
                      context: context,
                      initialDate: start,
                      firstDate: dateOnly(DateTime.now()),
                      lastDate: DateTime(9999, 12, 31));
                  setState(() {
                    start = date ?? start;
                    month = start.month;
                    monthDay = start.day;
                  });
                },
                color: Colors.black12,
              )),
            )
          ],
        ),
        padding: EdgeInsets.only(left: 10, top: 5, bottom: 5, right: 10),
      );
    } else if (frequency == Frequency.weekly) {
      return Container(
        child: Row(
          children: <Widget>[
            Padding(
              child: Text('Start'),
              padding: EdgeInsets.only(right: 5),
            ),
            Expanded(
              child: Container(
                  child: FlatButton(
                child: Align(
                  child: Text(
                    formatDate(start),
                    textAlign: TextAlign.left,
                  ),
                  alignment: Alignment.centerLeft,
                ),
                onPressed: () async {
                  DateTime date = await showDatePicker(
                      context: context,
                      initialDate: start,
                      firstDate: dateOnly(DateTime.now()),
                      lastDate: DateTime(9999, 12, 31));
                  setState(() {
                    start = date ?? start;
                    month = start.month;
                    monthDay = start.day;
                  });
                },
                color: Colors.black12,
              )),
            )
          ],
        ),
        padding: EdgeInsets.only(left: 10, top: 5, bottom: 5, right: 10),
      );
    } else if (frequency == Frequency.monthly) {
      return Container(
        child: Row(
          children: <Widget>[
            Padding(
              child: Text('Start'),
              padding: EdgeInsets.only(right: 5),
            ),
            Expanded(
              child: Container(
                child: Padding(
                  padding: EdgeInsets.only(left: 10, right: 5),
                  child: DropdownButton(
                    underline: null,
                    isExpanded: true,
                    value: month,
                    items: <DropdownMenuItem>[
                      DropdownMenuItem(
                        child: Text('January'),
                        value: 1,
                      ),
                      DropdownMenuItem(
                        child: Text('February'),
                        value: 2,
                      ),
                      DropdownMenuItem(
                        child: Text('March'),
                        value: 3,
                      ),
                      DropdownMenuItem(
                        child: Text('April'),
                        value: 4,
                      ),
                      DropdownMenuItem(
                        child: Text('May'),
                        value: 5,
                      ),
                      DropdownMenuItem(
                        child: Text('June'),
                        value: 6,
                      ),
                      DropdownMenuItem(
                        child: Text('July'),
                        value: 7,
                      ),
                      DropdownMenuItem(
                        child: Text('August'),
                        value: 8,
                      ),
                      DropdownMenuItem(
                        child: Text('September'),
                        value: 9,
                      ),
                      DropdownMenuItem(
                        child: Text('October'),
                        value: 10,
                      ),
                      DropdownMenuItem(
                        child: Text('November'),
                        value: 11,
                      ),
                      DropdownMenuItem(
                        child: Text('December'),
                        value: 12,
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        month = value;
                        start = DateTime(start.year, month, start.day);
                      });
                    },
                  ),
                ),
                color: Colors.black12,
                height: 35,
              ),
            )
          ],
        ),
        padding: EdgeInsets.only(left: 10, top: 5, bottom: 5, right: 10),
      );
    } else if (frequency == Frequency.yearly) {
      return Container(
        child: Row(
          children: <Widget>[
            Expanded(
              child: Container(
                  child: FlatButton(
                child: Align(
                  child: Text(
                    formatDate(start),
                    textAlign: TextAlign.left,
                  ),
                  alignment: Alignment.centerLeft,
                ),
                onPressed: () async {
                  DateTime date = await showDatePicker(
                      context: context,
                      initialDate: start,
                      firstDate: dateOnly(DateTime.now()),
                      lastDate: DateTime(9999, 12, 31));
                  setState(() {
                    start = date ?? start;
                    month = start.month;
                    monthDay = start.day;
                  });
                },
                color: Colors.black12,
              )),
            )
          ],
        ),
        padding: EdgeInsets.only(left: 10, top: 5, bottom: 5, right: 10),
      );
    } else {
      return Container();
    }
  }

  Widget nextOccurrence() {
    if (frequency == Frequency.weekly && byWeekDays.isEmpty) {
      return Container();
    } else {
      return Container(
        child: Text(
          'First occurrence will be ${formatDate(this.toRecurrenceRule().getInstances(start: LocalDateTime(start.year, start.month, start.day, 0, 0, 0)).first)}',
          style: TextStyle(color: Colors.black38, fontSize: 10),
        ),
        alignment: Alignment.bottomLeft,
        padding: EdgeInsets.only(left: 10),
      );
    }
  }

  Widget okButton() {
    if (frequency == Frequency.weekly && byWeekDays.isEmpty) {
      return Container(
        child: FlatButton(
            child: Text(
              'OK',
              style: TextStyle(
                color: Colors.black38,
              ),
            ),
            onPressed: null),
      );
    } else {
      return Container(
        child: FlatButton(
          child: Text(
            'OK',
            style: TextStyle(
              color: ConstantHelper.tomatoColor,
            ),
          ),
          onPressed: () {
            Navigator.pop(context, this.toRecurrenceRule());
          },
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    byWeekdaysInMonth = false;
    start = dateOnly(DateTime.now());
    frequency = Frequency.weekly;
    interval = 1;
    weekDay = ByWeekDayEntry(DayOfWeek(start.weekday));
    byWeekDays = {ByWeekDayEntry(DayOfWeek(start.weekday))};
    monthDay = start.day;
    week = getWeekNum(LocalDate(start.year, start.month, start.day));
    month = start.month;
    intervalController = TextEditingController(text: interval.toString());
    startController = TextEditingController(text: formatDate(start));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              child: Row(
                children: <Widget>[
                  Padding(
                    child: Text('Every'),
                    padding: EdgeInsets.only(right: 5),
                  ),
                  Padding(
                    child: Container(
                      child: TextFormField(
                        controller: intervalController,
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          WhitelistingTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(2),
                        ],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                        ),
                        onChanged: (s) {
                          if (s == '0') {
                            intervalController.text = '';
                          } else {
                            interval = int.parse(s);
                          }
                        },
                        onFieldSubmitted: (s) {
                          if (s == '')
                            intervalController.text = interval.toString();
                        },
                      ),
                      height: 30,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                      ),
                    ),
                    padding: EdgeInsets.only(left: 10, right: 10),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    height: 30,
                    color: Colors.black12,
                    child: DropdownButton(
                      items: <DropdownMenuItem>[
                        DropdownMenuItem(
                          child: Text('day'),
                          value: Frequency.daily,
                        ),
                        DropdownMenuItem(
                          child: Text('week'),
                          value: Frequency.weekly,
                        ),
                        DropdownMenuItem(
                          child: Text('month'),
                          value: Frequency.monthly,
                        ),
                        DropdownMenuItem(
                          child: Text('year'),
                          value: Frequency.yearly,
                        ),
                      ],
                      value: frequency,
                      onChanged: (value) {
                        setState(() => frequency = value);
                      },
                    ),
                  )
                ],
              ),
              padding: EdgeInsets.only(left: 10, top: 5, bottom: 5, right: 10),
            ),
            monthWeekSelection(),
            startSelection(),
            nextOccurrence(),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Container(),
                ),
                Container(
                  child: FlatButton(
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.black38,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context, null);
                    },
                  ),
                ),
                okButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
