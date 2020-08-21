import 'dart:async';
import 'dart:math';

import 'dart:isolate';

import 'package:dart_numerics/dart_numerics.dart';
import 'package:flutter/material.dart';
import 'package:timato/ui/basics.dart';
import 'package:timato/ui/timato_timer_widget.dart';

import 'notifications.dart';

/// Used to count down a pomodora timer
///
/// Setup an isolate to run the timer with duration of one second.
///
/// Passing in [timerLength] in second to determine length of the timer,
/// and using [_onData] to process the periodically listened data (the [_timerCount] of each second).
///
/// The counter will be set to be the same as the [timerLength] at the beginning.
/// When started, the [_timerCount] will count down, and when it hits zero, the relax status is activated.
/// Then, the [_timerCount] will count up from zero.
class TimatoTimer {
  final ReceivePort receivePort = ReceivePort();

  /// The length of the timer.
  /// If it is changed, kill the current TimatoTimer and create a new one.
  final int timerLength;

  final int relaxLength;

  /// It processes the periodically listened data (the [_timerCount] of each second)
  final void Function(int) _onData;

  Isolate _isolate;

  /// It checks whether the timer times out.
  /// Though it is private, you can still get it by using <TimatoTimer>.isRelax ([isRelax])
  bool _isRelax = false;

  /// The timer counter
  int _timerCount = 0;

  DateTime _startTime;

  /// The timer
  Timer _t;

  // Get the relax status of the timer
  bool get isRelax => _isRelax;

  /// Get the active status of the timer
  bool get isActive => _t.isActive;

  /// Creates a new TimatoTimer that initialte an isolate and set the [_timerCount] to be the [timerLength]
  TimatoTimer(this.timerLength, this.relaxLength, this._onData) {
    _timerCount = timerLength;
    _onData(_timerCount);
    receivePort.listen((message) {
      _timerCount = message[0];
      _isRelax = message[1];
      _onData(_timerCount);
    });
  }

  /// An async function that returns true when in the relax mode.
  /// It checks whether the timer is relax every 0.5 second.
  Future<bool> untilRelax() async {
    while (!_isRelax) {
      await Future.delayed(const Duration(milliseconds: 500));
    }
    return true;
  }

  /// Restore the timer
  void restore() {
    _isRelax = false;
    _timerCount = timerLength;
    _onData(_timerCount);
  }

  /// Start the timer
  void start() async {
    _startTime = DateTime.now();
    Map map = {
      'localization': TimatoLocalization.instance,
      'relaxLength': relaxLength,
      'timerCount': _timerCount,
      'startTime': _startTime,
      'isRelax': _isRelax,
      'port': receivePort.sendPort
    };
    _isolate = await Isolate.spawn(_startTimeout, map);
  }

  /// Stop the timer
  void stop() {
    _isolate?.kill();
//    if (_t == null) return;
//    _t.cancel();
  }

  /// Start a timer
  ///
  /// Start a timer with a minimum unit of one second.
  /// count down the timer
  static void _startTimeout(Map map) async {
    var localization = map['localization'];
    int relaxLength = map['relaxLength'];
    int timerCount = map['timerCount'];
    int timerStart = map['timerCount'];
    DateTime startTime = map['startTime'];
    bool isRelax = map['isRelax'];
    SendPort sendPort = map['port'];
    int count = 0;
    TimerStatus status = TimerStatus.normal;
    Timer.periodic(Duration(seconds: 1), (_) async {
      if (count++ == 5) {
        count = 0;
        int timeDiff =
            DateTime.now().difference(startTime).abs().inSeconds.round();
        timerCount = timerStart - timeDiff;
      } else {
        --timerCount;
      }
      sendPort.send([timerCount, isRelax]);
      if (timerCount <= 0) {
        isRelax = true;
      }
    });
  }
}
