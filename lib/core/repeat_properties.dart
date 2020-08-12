import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:rrule/rrule.dart';
import 'package:timato/ui/add_event.dart';
import 'package:time_machine/time_machine.dart';
import 'package:timato/ui/basics.dart';

class RepeatProeprties{
  final RecurrenceRule rule;
  LocalDateTime start;

  RepeatProeprties({@required this.rule, @required this.start});

  LocalDateTime nextOccurrence(){
    LocalDateTime nextOccurrence = rule.getInstances(start: start).firstWhere((element) => element >= start);
    return nextOccurrence;
  }

  static RepeatProeprties fromString(String str){
    if(str==null){
      return null;
    }
    var attributes = str.split('/');
    return RepeatProeprties(
      rule: RecurrenceRule.fromString(attributes[0]),
      start: DateTime.parse(attributes[1]).toLocalDateTime()
    );
  }

  @override
  String toString(){
    return '$rule/${dateOnly(start.toDateTimeLocal())}';
  }
}