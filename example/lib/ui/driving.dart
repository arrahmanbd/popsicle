import 'package:example/popsicle.dart';
import 'package:example/provider/driving_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:popsicle/popsicle.dart';

class DrivingScreen extends StatelessWidget {
  const DrivingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopWidget<String, DrivingLogic>(
      create: () => Popsicle.get<DrivingLogic>(),
      middleware: [
        (oldState, newState) {
          debugPrint('State changed: $oldState -> $newState');
          return newState;
        },
      ],
      builder: (context, value, logic) {
        print('rebuilding with value: $value');
        return Scaffold(
          appBar: AppBar(title: const Text('Driving Checker')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value, style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => logic.check(16),
                  child: const Text('Check Age 16'),
                ),
                ElevatedButton(
                  onPressed: () => logic.check(20),
                  child: const Text('Check Age 20'),
                ),

                Divider(height: 40, thickness: 2),
                const Text(
                  'Riverpod Example',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                const DrivingRiver(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class DrivingRiver extends ConsumerWidget {
  const DrivingRiver({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canDrive = ref.watch(drivingProvider);
    return Column(
      children: [
        Text(canDrive, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => ref.read(drivingProvider.notifier).check(16),
          child: const Text('Check Age 16'),
        ),
        ElevatedButton(
          onPressed: () => ref.read(drivingProvider.notifier).check(20),
          child: const Text('Check Age 20'),
        ),
      ],
    );
  }
}
