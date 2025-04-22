
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

### 1. Extend `AppDI` to register dependencies

```dart
class AppDI extends DIConfigurator {
  static final authService = container.reg<AuthService>(AuthServiceImpl());
  static final logger = container.regLazy(() => Logger());
}
```

### 2. Inject Popsicle in your app root (Optional 🙃)

```dart
void main() {
  runApp(
    PopsicleDI(
      app: const MyApp(),
      inject: () => AppDI(),
    ),
  );
}
```

### 3. Use anywhere (without context!)

```dart
final auth = Popsicle.instance<AuthService>();
auth.login();
```

### 4. Create a reactive state

```dart
final counter = ReactiveState<int>(0);

counter.listen((value) {
  print("Counter updated: $value");
});

counter.value++; // Counter updated: 1
```

---

## 🎯 Lifecycle Management

Popsicle supports lifecycle-aware widgets and cleanup:

```dart
class MyState extends ReactiveState<int> with Disposable {
  MyState() {
    startTimer();
  }

  void startTimer() {
    Timer.periodic(Duration(seconds: 1), (_) => value++);
  }

  @override
  void dispose() {
    print("Cleaning up MyState");
    super.dispose();
  }
}
```

---

## 🧪 Testing

```dart
final testContainer = DIContainer();
testContainer.registerSingleton<MockService>(MockService());

final service = testContainer.resolve<MockService>();
expect(service.doSomething(), true);
```

---

## 🧩 Extensions (Planned)

- ✅ Code generation for injectable services
- ✅ Integration with Riverpod, Bloc
- ✅ Dev tools inspector panel
- ✅ Web dashboard for live state inspection

---

## 📚 API Overview

| Feature          | Class/Method          | Description                                 |
|------------------|-----------------------|---------------------------------------------|
| DI Registration  | `container.registerSingleton<T>()`  | Register a singleton instance               |
| Lazy Singleton   | `container.registerFactory()` | Register a lazy-loaded singleton            |
| Reactive State   | `ReactiveState<T>`    | State that emits changes                    |
| Async State      | `AsyncState<T>`      | Handle async loading / error / data         |
| Stream State     | `StreamState<T>`     | Wrap a Dart stream as state                 |
| Global Access    | `Popsicle.instance<T>()`| Access service globally, no context needed  |

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
