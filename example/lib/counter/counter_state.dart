import 'package:flutter/material.dart';
import 'package:popsicle/popsicle.dart';

class CounterState {
  static final ReactiveState<int> counter = ReactiveProvider.createNotifier(
    'counter',
    0,
  );
  // Method to increment the 'counter' state
  void increment() => counter.update(counter.value + 1);
}

class CounterWidget extends StatelessWidget {
  const CounterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CounterState.counter.listen((value) {
      return Text('Counter: $value', style: const TextStyle(fontSize: 24));
    });
  }
}
