

<p align="center">
  <img src="https://github.com/arrahmanbd/popsicle/raw/master/images/icon.png" alt="App Icon" width="150"/>
</p>

# 🍡 Popsicle — Simple. Reactive. Composable

> `Popsicle` is a lightweight, extensible state management and dependency injection (DI) framework for Flutter, built with simplicity and power in mind. Designed for developers who want full control without boilerplate, `Popsicle` unifies state, DI, and lifecycle management under one clean architecture.

---

## 🚀 Features

- ✅ Reactive & composable state management (`ReactiveState`, `AsyncState`, `StreamState`)
- ✅ Built-in dependency injection without global variables
- ✅ Zero-boilerplate DI with centralized configuration via `AppDI` class
- ✅ Lifecycle-aware state observers & disposal
- ✅ Middleware support for state transformation or interception
- ✅ Supports Flutter & Dart CLI applications
- ✅ Designed for both small and large-scale apps
- ✅ Modular architecture for easy extensibility

---

## 📦 Installation

Add `popsicle` to your `pubspec.yaml`:

```yaml
dependencies:
  popsicle: ^1.0.0
```

Then run:

```bash
flutter pub get
```

---

## 🧠 Philosophy

Popsicle is inspired by the idea of:

```javascript
f(State) => UI
```

We believe the UI should be a pure function of state — with your logic encapsulated, testable, and clean.

---

## 🛠️ Getting Started

### 1. Set Up Dependency Injection

Create a class to register your dependencies with the `AppDI` container:

```dart
class Dependency implements AppDI {
  @override
  void initialize(DI di) {
    // Registering TodoService as a singleton
    di.registerSingleton<TodoService>(TodoService());

    // Registering TodoState with its dependency TodoService
    di.registerFactory<TodoState>(() => TodoState(di.resolve<TodoService>()));

    // Registering MyState as a factory
    di.registerFactory<MyState>(() => MyState());
  }
}
```

### 2. Initialize Popsicle DI in Your App

In your `main.dart`, bootstrap the app with the DI container:

```dart
void main() {
  startClock(); // Start the stream ticking
  // Bootstrap the app with the dependency injection container
  // and register the dependencies
  Popsicle.bootstrap(Dependency());
  runApp(const MyApp());
}
```

### 3. Create any Reactive State

Create a reactive state using `ReactiveState`, `AsyncState`, or `StreamState`:

```dart
// Counter State
final ReactiveState<int> counterState = ReactiveProvider.createNotifier<int>(
  0,
  key: 'counter',
);

// Stream Clock State (ticks every second)
final StreamState<int> streamClockState = ReactiveProvider.createStream<int>(
  'clock',
  0,
);

void startClock() {
  Timer.periodic(const Duration(seconds: 1), (_) {
    _tick++;
    streamClockState.update(_tick);
  });
}
```

### 4. Use Reactive State in UI

Popsicle simplifies using reactive states in your UI:

```dart
class ExamplePage extends StatelessWidget {
  const ExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Popsicle State Example')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
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
              onSuccess: (val) => Text(
                "Seconds elapsed: $val",
                style: const TextStyle(fontSize: 20),
              ),
              onError: (err) => Text("Error: $err"),
              onLoading: () => const CircularProgressIndicator(),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 🎯 Lifecycle Management

Popsicle supports lifecycle-aware widgets and cleanup:

```dart
class MyState extends PopsicleState<int> {
  MyState() : super(0);

  @override
  void onInit() {
    print('MyState initialized with value: $state');
  }

  @override
  void onDispose() {
    print('MyState disposed');
  }

  void increment() {
    state++;
    print('MyState incremented to: $state');
  }
}
```

---

## 📚 API Overview

| Feature          | Class/Method                 | Description                                 |
|------------------|------------------------------|---------------------------------------------|
| DI Registration  | `di.registerSingleton<T>()`   | Register a singleton instance               |
| Lazy Singleton   | `di.registerFactory<T>()`     | Register a lazy-loaded singleton            |
| Reactive State   | `ReactiveState<T>`            | State that emits changes                    |
| Async State      | `AsyncState<T>`               | Handle async loading / error / data         |
| Stream State     | `StreamState<T>`              | Wrap a Dart stream as state                 |
| Global Access    | `Popsicle.provider<T>()`      | Access service globally, no context needed  |

---

## 💡 Why Popsicle?

- No black-box magic
- Minimal boilerplate
- Pure Dart core
- Flutter-ready but framework-agnostic
- Clean architecture friendly

---

## 👥 Community

Coming soon: Discord + GitHub Discussions

---

## 🪪 License

Apache License 2.0 © [AR Rahman](https://github.com/arrahmanbd)

This project is licensed under the [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).

[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0)

---

## 💬 Feedback

Have ideas or suggestions? Feel free to open an issue or pull request!
