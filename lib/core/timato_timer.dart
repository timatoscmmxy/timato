import 'dart:async';

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
class TimatoTimer{
  /// The length of the timer.
  /// If it is changed, kill the current TimatoTimer and create a new one.
  final int timerLength;
  /// It processes the periodically listened data (the [_timerCount] of each second)
  final void Function(int) _onData;

  /// It checks whether the timer times out.
  /// Though it is private, you can still get it by using <TimatoTimer>.isRelax ([isRelax])
  var _isRelax = false;

  /// The timer counter
  var _timerCount = 0;
  /// The timer
  Timer _t;

  // Get the relax status of the timer
  bool get isRelax => _isRelax;
  /// Get the active status of the timer
  bool get isActive => _t.isActive;

  /// Creates a new TimatoTimer that initialte an isolate and set the [_timerCount] to be the [timerLength]
  TimatoTimer(this.timerLength, this._onData){
    _timerCount = timerLength;
    _onData(_timerCount);
  }

  /// An async function that returns true when in the relax mode.
  /// It checks whether the timer is relax every 0.5 second.
  Future<bool> untilRelax() async{
    while(!_isRelax){
      await Future.delayed(const Duration(milliseconds: 500));
    }
    return true;
  }

  /// Restore the timer
  void restore(){
    _isRelax = false;
    _timerCount = timerLength;
    _onData(_timerCount);
  }

  /// Start the timer
  void start() async{
    _startTimeout();
  }

  /// Stop the timer
  void stop(){
    _t.cancel();
  }

  /// Start a timer
  ///
  /// Start a timer with a minimum unit of one second.
  /// count down the timer
  void _startTimeout() async{
    _t = Timer.periodic(Duration(seconds: 1), (_) {
      _onData(--_timerCount);
      if (_timerCount <= 0){
        _isRelax = true;
      }
    });
  }
}