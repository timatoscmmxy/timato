import 'package:flutter/widgets.dart';
import 'package:test/test.dart';
import 'package:timato/core/event.dart';
import 'package:timato/ui/basics.dart';

main(){
  var event = Subevent(
    taskName: 'abla'
  );

  test("optional arguments", () => expect(event.eventPriority, Priority.NONE));

}