import 'package:rrule/rrule.dart';
import 'package:timato/core/repeat_properties.dart';

main(){
  RecurrenceRule rule = RecurrenceRule.fromString("RRULE:FREQ=MONTHLY;BYDAY=-3TU");
  print(rule);
}