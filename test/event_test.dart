import 'package:test/test.dart';
import 'package:timato/core/event.dart';

main(){
  var event = Subevent(
    taskName: 'abla'
  );

  test("optional arguments", () => expect(event.eventPriority, Priority.NONE));
}