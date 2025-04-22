import 'package:example/api/todo_screen.dart';
import 'package:example/counter/counter_state.dart';
import 'package:example/di.dart';
import 'package:flutter/material.dart';
import 'package:popsicle/popsicle.dart';

void main() {
  runApp(PopsicleDI(inject: () => AppDI(), app: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Popsicle Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Popsicle Demo')),
      body: Column(
        children: [
          CounterWidget(),
          const SizedBox(height: 20),
          Expanded(child: TodoScreen()),
        ],
      ),
    );
  }
}

/// NO Context Required
/// Example f(State)
/// Your Service
class LoggerService {
  void log(String message) {
    debugPrint("[Logger] $message");
  }
}

/// Your Controller that uses global inject()
class MyController {
  final logger = inject<LoggerService>();

  void doSomething() {
    logger.log("Something happened");
  }
}

/// UI
class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = inject<MyController>();
    return Scaffold(
      appBar: AppBar(title: const Text("Global DI Access")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => controller.doSomething(),
          child: const Text("Log Something"),
        ),
      ),
    );
  }
}
