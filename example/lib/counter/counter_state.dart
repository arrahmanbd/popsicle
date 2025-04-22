import 'package:flutter/material.dart';
import 'package:popsicle/popsicle.dart';

class CounterState2 {
  static final ReactiveState<int> counter = ReactiveProvider.createNotifier(
    'counter',
    0,
  );
  // Method to increment the 'counter' state
  void increment() => counter.update(counter.value + 1);
}



class CounterState3 extends Popsicle {
  final counter = ReactiveState(0);

  void increment() => counter.update(counter.value + 1);

  @override
  List<ReactiveState> get states => [counter];
}

class CounterWidget extends StatelessWidget {
  const CounterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CounterState2.counter.listen((value) {
      return Text('Counter: $value', style: const TextStyle(fontSize: 24));
    });
  }
}


// sccope and global support
class CounterState {
  final ReactiveState<int> counter;

  CounterState._(this.counter);

  factory CounterState.global() {
    final state = ReactiveProvider.createNotifier('counter', 0);
    return CounterState._(state);
  }

  factory CounterState.scoped(String scopeName) {
    final scope = ReactiveScopeManager.scope(scopeName);
    final state = scope.use<ReactiveState<int>>('counter', () => ReactiveState(0));
    return CounterState._(state);
  }

  void increment() => counter.update(counter.value + 1);
}


//usease
final globalCounter = CounterState.global();