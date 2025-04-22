import 'package:example/api/todo_screen.dart';
import 'package:example/async.dart';
import 'package:example/counter/counter_state.dart';
import 'package:example/di.dart';
import 'package:flutter/material.dart';
import 'package:popsicle/popsicle.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize the Popsicle DI container
  Popsicle.bootstrap(AppDI());
  runApp(MyApp());
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

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _card(Widget child) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),

      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(padding: const EdgeInsets.all(18.0), child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(title: const Text('Popsicle Demo')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _sectionTitle("Async State"),
                  _card(
                    userFuturedata.listen(
                      onSuccess:
                          (data) => Text(
                            "👤 User: ${data['name']}, 🎮 Level: ${data['level']}",
                            style: const TextStyle(fontSize: 18),
                          ),
                      onError:
                          (error) => Text(
                            "❌ Error: $error",
                            style: const TextStyle(color: Colors.red),
                          ),
                      onLoading:
                          () =>
                              const Center(child: CircularProgressIndicator()),
                    ),
                  ),
                  _sectionTitle("Reactive State"),
                  _card(const CounterWidget()),
                  _sectionTitle("User Stream State"),

                  //   _sectionTitle("Todo List"),
                  //  Flexible(child: TodoScreen()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// NO Context Required
/// Example  of using Popsicle without context
/// This is useful for services, controllers, or any other logic that doesn't need
/// to be tied to a specific widget tree.
/// You can use the global `inject()` function to access your dependencies
/// without needing to pass the context around.
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
