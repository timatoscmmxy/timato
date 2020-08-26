import 'dart:async';
import 'dart:math';

import 'dart:isolate';
import 'dart:ui';

import 'package:dart_numerics/dart_numerics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timato/ui/basics.dart';
import 'package:timato/ui/timato_timer_widget.dart';

import 'notifications.dart';

class TimatoTimerPlugin{
  static const MethodChannel _channel =
  const MethodChannel('plugins.flutter.io/timato_timer_plugin');

  static void callbackDispatcher() {
    const MethodChannel _backgroundChannel =
    MethodChannel('plugins.flutter.io/timato_timer_plugin_background');

    WidgetsFlutterBinding.ensureInitialized();

    // 2. Listen for background events from the platform portion of the plugin.
    _backgroundChannel.setMethodCallHandler((MethodCall call) async {
      final args = call.arguments;

      // 2.1. Retrieve callback instance for handle.
      final Function callback = PluginUtilities.getCallbackFromHandle(
          CallbackHandle.fromRawHandle(args[0]));
      assert(callback != null);



      callback();
    });

    _backgroundChannel.invokeMethod('TimatoTimerService.initialized');
  }

  static void initialize() async {
    final callback = PluginUtilities.getCallbackHandle(callbackDispatcher);
    await _channel.invokeMethod('TimatoTimerPlugin.initializeService',
        <dynamic>[callback.toRawHandle()]);
  }
}

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
      notifications.show(2, "TimatoEvent", secondToString(_timerCount), countdownNotificationDetails);
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
    notifications.cancelAll();
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
    notifications.cancel(2);
  }

  /// Start a timer
  ///
  /// Start a timer with a minimum unit of one second.
  /// count down the timer
  static void _startTimeout(Map map) async {
    int timerCount = map['timerCount'];
    int timerStart = map['timerCount'];
    DateTime startTime = map['startTime'];
    bool isRelax = map['isRelax'];
    SendPort sendPort = map['port'];
    Timer.periodic(Duration(milliseconds: 500), (_) async {
      int timeDiff =
          DateTime.now().difference(startTime).abs().inSeconds.round();
      timerCount = timerStart - timeDiff;
      sendPort.send([timerCount, isRelax]);
      if (timerCount <= 0) {
        isRelax = true;
      }
    });
  }
}
