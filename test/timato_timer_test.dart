import 'dart:async';
import 'package:test/test.dart';

import 'package:timato/core/timato_timer.dart';

var msg, count, timer;

Future<String> testTimer1() async{
  // expected == "543210"
  count = 0;
  msg = "";
  void onData(data){
    count = data;
    msg += data.toString();
    if(data == 0){
      timer.stop();
    }
  }
  //TODO:
  // timer = TimatoTimer(5, onData);
  timer.start();
  await timer.untilRelax();
  return msg;
}

Future<String> testTimer2() async{
  // expected == "54321012345"
  count = 0;
  msg = "";
  void onData(data){
    count = data;
    msg += data.toString();
  }
  // timer = TimatoTimer(5, onData);
  timer.start();
  while(!(timer.isRelax && count == 5)){
    await Future.delayed(const Duration(milliseconds: 500));
  }
  timer.stop();
  return msg;
}

Future<String> testTimer3() async{
  // expected == "5432"
  count = 0;
  msg = "";
  void onData(data){
    count = data;
    msg += data.toString();
  }
  // timer = TimatoTimer(5, onData);
  timer.start();
  while(count != 2){
    await Future.delayed(const Duration(milliseconds: 500));
  }
  timer.stop();
  return msg;
}

Future<String> testTimer4() async{
  // expected == "5432+10"
  count = 0;
  msg = "";
  void onData(data){
    count = data;
    msg += data.toString();
  }
  // timer = TimatoTimer(5, onData);
  timer.start();
  while(count != 2){
    await Future.delayed(const Duration(milliseconds: 500));
  }
  timer.stop();
  msg += "+";
  timer.start();
  await timer.untilRelax();
  timer.stop();
  return msg;
}

Future<String> testTimer5() async{
  // expected == "5432543210"
  count = 0;
  msg = "";
  void onData(data){
    count = data;
    msg += data.toString();
  }
  // timer = TimatoTimer(5, onData);
  timer.start();
  while(count != 2){
    await Future.delayed(const Duration(milliseconds: 500));
  }
  timer.stop();
  timer.restore();
  timer.start();
  await timer.untilRelax();
  timer.stop();
  return msg;
}

void main() async{
  var result1 = await testTimer1();
  test("count until relax", () => expect(result1, "543210"));

  var result2 = await testTimer2();
  test("count to relax then to 5", () => expect(result2, "54321012345"));

  var result3 = await testTimer3();
  test("pause at 2", () => expect(result3, "5432"));

  var result4 = await testTimer4();
  test("pause at 2 and continue to relax", () => expect(result4, "5432+10"));

  var result5 = await testTimer5();
  test("pause at 2, restore, and then to relax", () => expect(result5, "5432543210"));
}