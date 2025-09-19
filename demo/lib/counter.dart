import 'package:flutter/material.dart';
import 'package:micro_state_example/stream.dart';
import 'package:micro_state_example/toggle.dart';
import 'package:popsicle/popsicle.dart';

// Example async function to fetch data
Future<String> fetchData() async {
  await Future.delayed(const Duration(seconds: 2));
  return 'Fetched Data!';
}

class CounterState extends PopsicleState<int> {
  CounterState() : super(state: 0);
  void increment() => shift(state + 1);
  void decrement() => shift(state - 1);
}

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final counter = CounterState();
    print(counter.state);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CounterStreamPage(),
          PopWidget<String?, PopSync<String>>(
            create: () => PopSync(state: '')..runAsync(fetchData),
            builder: (context, value, logic) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (logic.currentSignal == PopsicleSignal.watch)
                    const CircularProgressIndicator()
                  else
                    Text(value ?? 'No data',
                        style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => logic.runAsync(fetchData),
                    child: const Text('Reload'),
                  ),
                ],
              );
            },
          ),
          counter.view(
            (value) => Text(
              'Quantum Value: ${value ?? 0}',
              style: const TextStyle(fontSize: 28),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Entangle +1'),
                onPressed: counter.increment,
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.remove),
                label: const Text('Collapse -1'),
                onPressed: counter.decrement,
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Expanded(child: QuantumTogglePage()),
        ],
      ),
    );
  }
}
