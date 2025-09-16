import 'package:example/api_example/todo_screen.dart';
import 'package:example/dependency.dart';
import 'package:example/popsicle/new_state.dart';
import 'package:example/popsicle/state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:popsicle/popsicle.dart';

void main() {
  startClock(); // Start the stream ticking
  // Bootstrap the app with the dependency injection container
  // and register the dependencies
  Popsicle.bootstrap(Dependency());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ExamplePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ExamplePage extends StatelessWidget {
  const ExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('Widget not rebuilding');
    }
    // 1. Logging Middleware
    int loggingMiddleware<int>(context) {
      if (kDebugMode) {
        print(
          '[LOG] State for "${context.key}" changed: ${context.oldValue} → ${context.newValue}',
        );
      }
      return context.newValue;
    }

    counterState.addMiddleware(loggingMiddleware);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Popsicle State Example'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sticky_note_2),
            tooltip: 'Todo List',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TodoScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("🧮 Counter", style: TextStyle(fontSize: 18)),

              counterState.view(
                (value) => Row(
                  children: [
                    Text("Value: $value", style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => counterState.update(value + 1),
                      child: const Text("Increment"),
                    ),
                  ],
                ),
              ),
              const Divider(height: 40),

              const Text("⏱️ Stream Clock", style: TextStyle(fontSize: 18)),
              streamClockState.view(
                onSuccess:
                    (val) => Text(
                      "Seconds elapsed: $val",
                      style: const TextStyle(fontSize: 20),
                    ),
                onError: (err) => Text("Error: $err"),
                onLoading: () => const CircularProgressIndicator(),
              ),
              const Divider(height: 40),

              const Text("📡 Async Greeting", style: TextStyle(fontSize: 18)),
              greetingState.view(
                onSuccess:
                    (data) => Text(
                      "Message: $data",
                      style: const TextStyle(fontSize: 20),
                    ),
                onError: (err) => Text("Error: $err"),
                onLoading:
                    () => const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
              ),
              const Divider(height: 40),
              const Text("🔔 State Notify", style: TextStyle(fontSize: 20)),
              SizedBox(height: 10),
              stateNotify.view(
                (state) =>
                    state.isLoading
                        ? CupertinoActivityIndicator()
                        : Text(
                          state.message,
                          style: const TextStyle(fontSize: 20),
                        ),
              ),
              ElevatedButton(
                onPressed: () => updateMessage("Hello Popsicle!"),
                child: const Text("Hello"),
              ),
              const Divider(height: 40),
              const Text("🔔 New State Notify", style: TextStyle(fontSize: 20)),
              SizedBox(height: 10),
              myState.view(
                (state) => Text(
                  state.toString(),
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              ElevatedButton(
                onPressed: () => myState.increment(),
                child: const Text("Increment"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
