import 'dart:async';

import 'package:popsicle/popsicle.dart';

class CounterLogic extends Logic<int> {
  CounterLogic() : super(0);
  void increment() => shift(state + 1);
  void decrement() => shift(state - 1);
}

void function() {
  final logic = PopLogic.use<CounterLogic>();
  logic.increment();
  logic.decrement();

  final logic2 = useLogic<CounterLogic>();
  logic2.increment();
  logic2.decrement();
}

class CounterStreamLogic extends Logic<int> {
  CounterStreamLogic() : super(0);

  Timer? _timer;

  /// Start the counter stream
  void startCounter() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      shift(state + 1); // emit new counter value
    });
  }

  /// Stop the counter
  void stopCounter() {
    _timer?.cancel();
  }

  @override
  void collapse() {
    _timer?.cancel();
    super.collapse();
  }
}
