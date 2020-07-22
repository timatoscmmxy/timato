import 'package:meta/meta.dart';

enum RepeatUnit { day, week, month, year }

enum RepeatWeekNum { First, Second, Third, Fourth, Last }

enum RepeatMonthType {day, week}

class RepeatProperties {
  /// The unit of repeating time
  RepeatUnit unit;

  /// Either be [RepeatMonthType.day] or [RepeatUnit.week]
  RepeatMonthType repeatMonthType;

  /// Repeat Every [unitNum] [unit]
  int unitNum;

  /// The date starts calculation
  DateTime start;

  /// The date that the events repeats if [unit] is [RepeatUnit.year]
//  DateTime repeatDate;

  /// Repeat every weekday if [unit] is [RepeatUnit.week]
  List<int> weekdays;

  /// Repeat on every [weekNum] [monthWeekday] if [unit] is [RepeatUnit.month]
  int startMonth;
  int monthWeekday;
  RepeatWeekNum weekNum;

  /// Repeat every monthDay if [unit] is [RepeatUnit.month]
  /// 0 is the last day of the month, otherwise, 1 <= [monthDay] <= 31
  int monthDay;

  RepeatProperties(){
    unit = RepeatUnit.week;
    unitNum = 1;
    repeatMonthType = RepeatMonthType.day;
    DateTime today = DateTime.now();
    start = today;
//    repeatDate = today;
    startMonth = today.month;
    weekdays = [today.weekday];
    monthWeekday = today.weekday;
    weekNum = getWeekNum(today);
    monthDay = today.day;
  }

  /// Determine whether today is the repeated date
  @deprecated
  bool isToday(DateTime today) {
    if (start.isAfter(today)) return false;

    Duration diff = start.difference(today);
    switch (this.unit) {
      case RepeatUnit.day:
        return diff.inDays % unitNum == 0;
        break;
      case RepeatUnit.week:
        return weekdays.contains(today.weekday) &&
            (this._diffInWeek(today, diff) % unitNum == 0);
        break;
      case RepeatUnit.month:
        if (this._diffInMonth(today) % unitNum == 0) {
          return (monthDay == today.day)
              // monthDay == 0 means last day in the month
              ||
              (monthDay == 0 &&
                  today.day ==
                      DateTime(today.year, today.month + 1, 1)
                          .add(Duration(days: -1))
                          .day)
              // nth Weekday situation
              ||
              (today.weekday == weekdays[0] && _nthWeekdayMatches(today));
        } else {
          return false;
        }
        break;
      case RepeatUnit.year:
        return today.isAtSameMomentAs(start) &&
            ((today.year - start.year) % unitNum == 0);
        break;
      default:
        return false;
    }
  }

  /// turn [diff] in days into difference in weeks between [today] and [start]
  int _diffInWeek(DateTime today, Duration diff) {
    int num = diff.inDays ~/ DateTime.daysPerWeek;
    if (today.weekday < this.start.weekday) ++num;
    return num;
  }

  /// return difference in months between [today] and [start]
  int _diffInMonth(DateTime today) {
    return (today.year - start.year) * 12 + (today.month - start.month);
  }

  /// Check whether [today] is the [weekNum]th weekday
  bool _nthWeekdayMatches(DateTime today) {
    int day = today.day;
    int weekday = today.weekday;
    int firstWeekdayInMonth = DateTime(today.year, today.month, 1).weekday;
    DateTime lastDayInMonth =
    DateTime(today.year, today.month + 1, 1).add(Duration(days: -1));
    int lastWeekdayInMonth = lastDayInMonth.weekday;
    int firstOccurrence = weekday >= firstWeekdayInMonth
        ? (weekday - firstWeekdayInMonth) + 1
        : (8 - firstWeekdayInMonth) + weekday;
    int lastOccurrence = weekday <= lastWeekdayInMonth
        ? lastDayInMonth.day - (lastWeekdayInMonth - weekday)
        : lastDayInMonth.day - 7 + (weekday - lastWeekdayInMonth);
    switch (this.weekNum) {
      case RepeatWeekNum.First:
        return day == firstOccurrence;
        break;
      case RepeatWeekNum.Second:
        return day == firstOccurrence + 7;
        break;
      case RepeatWeekNum.Third:
        return day == firstOccurrence + 14;
        break;
      case RepeatWeekNum.Fourth:
        return day == firstOccurrence + 21;
        break;
      case RepeatWeekNum.Last:
        return day == lastOccurrence;
        break;
      default:
        return false;
    }
  }
}

RepeatWeekNum getWeekNum(DateTime date) {
  DateTime firstDay = DateTime(date.year, date.month, 1);
  DateTime lastDay =
  DateTime(date.year, date.month + 1, 1).add(Duration(days: -1));
  int firstSunday = 1 + (7 - firstDay.weekday);
  int lastMonday = 31 - lastDay.weekday + 1;
  if (date.day <= firstSunday) {
    return RepeatWeekNum.First;
  } else if (date.day <= firstSunday + 7) {
    return RepeatWeekNum.Second;
  } else if (date.day <= firstSunday + 14) {
    return RepeatWeekNum.Third;
  } else if (date.day <= firstSunday + 21) {
    if (date.day >= lastMonday) {
      return RepeatWeekNum.Last;
    } else {
      return RepeatWeekNum.Fourth;
    }
  } else {
    return RepeatWeekNum.Last;
  }
}