// import 'package:example/logic/driving_logic.dart';
// import 'package:example/middleware/driving_middleware.dart.dart';
// import 'package:flutter/material.dart';
// import 'package:popsicle/popsicle.dart';

// class DrivingUI extends StatelessWidget {
//   const DrivingUI({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return LogicProvider<DrivingLogic>(
//       create: () => DrivingLogic(),
//       //middleware: [DrivingMiddleware(context)],
//       builder: (context, logic) {
//         return Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text("Age: ${logic.state}", style: const TextStyle(fontSize: 24)),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () => logic.setAge(16),
//               child: const Text("Set Age 16"),
//             ),
//             ElevatedButton(
//               onPressed: () => logic.setAge(20),
//               child: const Text("Set Age 20"),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
