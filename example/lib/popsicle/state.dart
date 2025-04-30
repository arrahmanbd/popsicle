import 'dart:async';
import 'package:example/popsicle/model.dart';
import 'package:flutter/foundation.dart';
import 'package:popsicle/popsicle.dart';

// Counter State
final ReactiveState<int> counterState = ReactiveProvider.createNotifier<int>(
  0,
  key: 'counter',
);

// Stream Clock State (ticks every second)
final StreamState<int> streamClockState = ReactiveProvider.createStream<int>(
  'clock',
  0,
);

Timer? _streamTimer;
int _tick = 0;

// Call this once in main to start ticking
void startClock() {
  _streamTimer ??= Timer.periodic(const Duration(seconds: 1), (_) {
    _tick++;
    streamClockState.update(_tick);
  });
}

// Async Notifier (simulated greeting fetch)
final AsyncNotifierState<String> greetingState = AsyncNotifierState(() async {
  await Future.delayed(const Duration(seconds: 2));
  return "Hello from Async!";
});

final ReactiveState<StateExample> stateNotify =
    ReactiveProvider.createNotifier<StateExample>(
      StateExample(isLoading: true, message: ''),
    );

void updateMessage(String message) {
  final time = ReactiveProvider.get<int>('counter')!.value;
  if (kDebugMode) {
    print(time);
  }
  // Dispose the previous state
  // Update the message while keeping the current loading state
  stateNotify.update(
    stateNotify.value.copyWith(
      message: "$message - ${time.toString()}",
      isLoading: false,
    ),
  );
}
