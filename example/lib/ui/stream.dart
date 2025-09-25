import 'package:example/logic/counter_logic.dart';
import 'package:flutter/material.dart';
import 'package:popsicle/popsicle.dart';

class CounterStreamPage extends StatelessWidget {
  const CounterStreamPage({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = Popsicle.get<CounterStreamLogic>();

    return Scaffold(
      appBar: AppBar(title: const Text('Counter Stream')),
      body: PopWidget<int, CounterStreamLogic>(
        keepAlive: false,
        create: () => logic,
        middleware: [
          (current, next) {
            print('CounterStreamLogic changed: $current -> $next');
            if (next == 10) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Counter reached 10!'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
            return next;
          },
        ],
        builder: (context, value, logic) {
          return Center(
            child: Text(
              '$value',
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'start',
            onPressed: logic.startCounter,
            tooltip: 'Start',
            child: const Icon(Icons.play_arrow),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: 'stop',
            onPressed: logic.stopCounter,
            tooltip: 'Stop',
            child: const Icon(Icons.stop),
          ),
        ],
      ),
    );
  }
}
