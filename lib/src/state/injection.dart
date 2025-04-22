part of '../../popsicle.dart';

/// Abstract class for configuration logic.
abstract class DIConfigurator {
  void configure(DIContainer container);
}

/// A function that returns a [DIConfigurator] instance.
typedef ConfigBuilder = DIConfigurator Function();

/// An [InheritedWidget] that provides access to the [DIContainer].
class PopsicleDI extends InheritedWidget {
  final DIContainer container;
  static DIContainer? _globalContainer;
  const PopsicleDI._({required this.container, required super.child});

  /// The main constructor with optional [inject] parameter for auto-configuration.
  factory PopsicleDI({required Widget app, ConfigBuilder? inject}) {
    final container = DIContainer();

    // Run the configurator if provided
    if (inject != null) {
      inject().configure(container);
    }
    _globalContainer = container; //  Set global access
    return PopsicleDI._(container: container, child: app);
  }

  /// Access the container from the [BuildContext].
  static DIContainer of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<PopsicleDI>();
    if (provider == null) {
      throw Exception('No DIProvider found in context');
    }
    return provider.container;
  }

  static DIContainer get global {
    final container = _globalContainer;
    if (container == null) {
      throw Exception('Global DIContainer is not initialized');
    }
    return container;
  }

  @override
  bool updateShouldNotify(PopsicleDI oldWidget) => false;
}

/// Extension on [BuildContext] to get registered types easily.
extension DIContextX on BuildContext {
  T get<T>() => PopsicleDI.of(this).resolve<T>();
}

/// Enum to distinguish between factory and singleton.
enum _EntryType { factory, singleton }

/// Internal storage for dependency entries.
class _DIEntry {
  final Function factory;
  final _EntryType type;

  _DIEntry(this.factory, this.type);
}

/// Dependency container holding all factories and singletons.
class DIContainer {
  final Map<Type, _DIEntry> _factories = {};
  final Map<Type, dynamic> _instances = {};

  /// Register a new factory type.
  void registerFactory<T>(T Function() factory) {
    _factories[T] = _DIEntry(factory, _EntryType.factory);
  }

  /// Register a singleton instance.
  void registerSingleton<T>(T instance) {
    _instances[T] = instance;
  }

  /// Register a lazy singleton (instantiated when first resolved).
  void registerSingletonLazy<T>(T Function() lazyFactory) {
    registerFactory<T>(() {
      final instance = lazyFactory();
      registerSingleton<T>(instance);
      return instance;
    });
  }

  /// Resolve a type [T] from the container.
  T resolve<T>() {
    if (_instances.containsKey(T)) {
      return _instances[T] as T;
    }

    if (_factories.containsKey(T)) {
      final entry = _factories[T]!;
      final instance = entry.factory();
      if (entry.type == _EntryType.singleton) {
        _instances[T] = instance;
      }
      return instance as T;
    }

    throw Exception("Dependency of type $T is not registered");
  }

  /// Clear all instances and factories.
  void clear() {
    _instances.clear();
    _factories.clear();
  }
}
