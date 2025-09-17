import 'dart:async';

import 'package:flutter/material.dart';
import 'package:popsicle/popsicle.dart';

/// Counter logic using StreamQuantumBox.
/// Emits an incrementing integer every second.
class CounterStreamLogic extends PopStream<int> {
  StreamSubscription<int>? _counterSubscription;

  CounterStreamLogic({required super.state});

  /// Start emitting a new counter value every second
  void startCounter() {
    // Cancel any existing subscription
    _counterSubscription?.cancel();

    _counterSubscription = Stream<int>.periodic(
      const Duration(seconds: 1),
      (count) => count + 1,
    ).listen(
      (value) => shift(value, signal: PopsicleSignal.refresh),
      onDone: () => sendSignal(PopsicleSignal.done),
      onError: (_) => sendSignal(PopsicleSignal.end),
    );
  }

  /// Stop the counter stream safely
  void stopCounter() {
    _counterSubscription?.cancel();
    _counterSubscription = null;
    sendSignal(PopsicleSignal.done);
  }

  @override
  void collapse() {
    stopCounter();
    super.collapse();
  }
}

/// Professional Counter Stream Page using QuantumWidget
class CounterStreamPage extends StatelessWidget {
  const CounterStreamPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopWidget<int, CounterStreamLogic>(
      create: () => CounterStreamLogic(state: 0)..startCounter(),
      builder: (context, value, logic) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Display current counter
              Text(
                'Counter: $value',
                style:
                    const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Display current quantum signal
              Text(
                'Signal: ${logic.currentSignal}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // Start / Stop button
              ElevatedButton(
                onPressed: () {
                  if (logic.currentSignal == PopsicleSignal.done ||
                      logic.currentSignal == PopsicleSignal.idle) {
                    logic.startCounter();
                  } else {
                    logic.stopCounter();
                  }
                },
                child: Text(
                  logic.currentSignal == PopsicleSignal.done ||
                          logic.currentSignal == PopsicleSignal.idle
                      ? 'Start Counter'
                      : 'Stop Counter',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
