import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:rrule/rrule.dart';
import 'package:timato/ui/add_event.dart';
import 'package:time_machine/time_machine.dart';

class RepeatProeprties{
  final RecurrenceRule rule;
  LocalDateTime start;

  RepeatProeprties({@required this.rule, @required this.start});

  LocalDateTime nextOccurrence(){
    LocalDateTime nextOccurrence = rule.getInstances(start: start).firstWhere((element) => element >= start);
    start = nextOccurrence;
    return nextOccurrence;
  }

  @override
  String toString(){
    return '$rule, start: ${formatDate(start)}';
  }
}