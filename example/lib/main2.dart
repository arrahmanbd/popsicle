
// import 'package:example/ui/driving.dart';
// import 'package:flutter/material.dart';
// import 'package:popsicle/popsicle.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   // Bootstrap: only register pure logic/state that do not rely on BuildContext.
//   // Avoid registering middleware which requires context (snackbars/nav) here.
//   // PopsicleLocator.bootstrap({
//   //   CounterLogic: CounterLogic(),
//   //   DrivingLogic: DrivingLogic(),
//   // });
//   runApp(const PopsicleDemoApp());
// }

// class PopsicleDemoApp extends StatelessWidget {
//   const PopsicleDemoApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Popsicle Demo',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: Scaffold(
//         appBar: AppBar(title: const Text("Popsicle Example")),
//         body: const DemoHome(),
//       ),
//     );
//   }
// }

// class DemoHome extends StatelessWidget {
//   const DemoHome({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ListView(
//       padding: const EdgeInsets.all(24),
//       children: const [
//         Text(
//           "🧮 Counter Example",
//           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//         ),
//         SizedBox(height: 12),
//         //CounterUI(),
//         Divider(height: 48),
//         Text(
//           "🚗 Driving Checker",
//           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//         ),
//         SizedBox(height: 12),
//         DrivingUI(),
//       ],
//     );
//   }
// }
