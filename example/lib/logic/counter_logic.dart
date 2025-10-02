import 'dart:async';

import 'package:popsicle/popsicle.dart';

class CounterLogic extends Logic<int> {
  final streamval = useLogic<CounterStreamLogic>();
  CounterLogic() : super(0) {
    shift(streamval.state);
  }
  void increment() => shift(state + 1);
  void decrement() => shift(state - 1);
  void listenOtherState() => shift(streamval.state);
}

class CounterStreamLogic extends Logic<int> {
  CounterStreamLogic() : super(0);

  Timer? _timer;
  bool _isPaused = false;
  int _counter = 0;

  /// Start the counter from 0
  void startCounter() {
    stopCounter(); // Ensure clean start
    _counter = 0;
    shift(_counter, signal: PopsicleSignal.refresh); // signal = refresh
    _startTimer();
  }

  /// Resume from the last value
  void resumeCounter() {
    if (_isPaused) {
      _isPaused = false;
      shift(_counter, signal: PopsicleSignal.emit); // signal = emit
      _startTimer();
    }
  }

  /// Pause but keep the last value
  void pauseCounter() {
    if (_timer != null) {
      _isPaused = true;
      _timer?.cancel();
      _timer = null;
      sendSignal(PopsicleSignal.update); // signal = update for pause
    }
  }

  /// Stop and reset
  void stopCounter() {
    _timer?.cancel();
    _timer = null;
    _isPaused = false;
    _counter = 0;
    shift(_counter, signal: PopsicleSignal.done); // signal = done
  }

  /// Internal helper to start ticking
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        _counter++;
        shift(_counter, signal: PopsicleSignal.emit); // regular tick
      }
    });
  }

  @override
  void collapse() {
    _timer?.cancel();
    super.collapse();
  }

  // Optional helpers for UI
  bool get isRunning => _timer != null && !_isPaused;
  bool get isPaused => _isPaused;
}
