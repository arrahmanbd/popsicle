import 'package:example/logic/counter_logic.dart';
import 'package:flutter/material.dart';
import 'package:popsicle/popsicle.dart';

class CounterStreamPage extends StatelessWidget {
  const CounterStreamPage({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = Popsicle.use<CounterStreamLogic>();

    return Scaffold(
      appBar: AppBar(title: const Text('Counter Stream')),
      body: PopWidget<int, CounterStreamLogic>(
        keepAlive: true,
        create: () => logic,
        builder: (context, value, logic) {
          // ✅ Access the current signal
          final signal = logic.currentSignal;

          // ✅ Side-effects safely using addPostFrameCallback
          if (value == 10 && signal == PopsicleSignal.emit) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Counter reached 10!'),
                  duration: Duration(seconds: 2),
                ),
              );
            });
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$value',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Signal: $signal',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
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
            heroTag: 'pause',
            onPressed: logic.pauseCounter,
            tooltip: 'Pause',
            child: const Icon(Icons.pause),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: 'resume',
            onPressed: logic.resumeCounter,
            tooltip: 'Resume',
            child: const Icon(Icons.play_arrow_rounded),
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

// class CounterStreamPage extends StatelessWidget {
//   const CounterStreamPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final logic = Popsicle.get<CounterStreamLogic>();

//     return Scaffold(
//       appBar: AppBar(title: const Text('Counter Stream')),
//       body: PopWidget<int, CounterStreamLogic>(
//         keepAlive: true,
//         create: () => logic,
//         middleware: [
//           (current, next) {
//             if (!context.mounted) return next; // ✅ exit if widget gone
//             debugPrint('CounterStreamLogic changed: $current -> $next');
//             if (next == 10) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text('Counter reached 10!'),
//                   duration: Duration(seconds: 2),
//                 ),
//               );
//             }
//             return next;
//           },
//         ],
//         builder: (context, value, logic) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   '$value',
//                   style: const TextStyle(
//                     fontSize: 64,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Text(
//                   logic.isRunning
//                       ? (logic.isPaused ? "Paused" : "Running")
//                       : "Stopped",
//                   style: TextStyle(
//                     fontSize: 18,
//                     color: logic.isPaused
//                         ? Colors.orange
//                         : logic.isRunning
//                         ? Colors.green
//                         : Colors.red,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//       floatingActionButton: Wrap(
//         spacing: 16,
//         children: [
//           FloatingActionButton(
//             heroTag: 'start',
//             onPressed: logic.startCounter,
//             tooltip: 'Start',
//             child: const Icon(Icons.play_arrow),
//           ),
//           FloatingActionButton(
//             heroTag: 'pause',
//             onPressed: logic.pauseCounter,
//             tooltip: 'Pause',
//             child: const Icon(Icons.pause),
//           ),
//           FloatingActionButton(
//             heroTag: 'resume',
//             onPressed: logic.resumeCounter,
//             tooltip: 'Resume',
//             child: const Icon(Icons.play_circle_fill),
//           ),
//           FloatingActionButton(
//             heroTag: 'stop',
//             onPressed: logic.stopCounter,
//             tooltip: 'Stop',
//             child: const Icon(Icons.stop),
//           ),
//         ],
//       ),
//     );
//   }
// }
