part of '../../popsicle.dart';

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
  final Map<Type, Future<dynamic>> _asyncCache = {};

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

  /// Register an async singleton (awaited when first resolved).
  void registerAsyncSingleton<T>(Future<T> Function() factory) {
    _asyncCache[T] = factory();
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

    throw Exception("Dependency of type <$T> is not registered");
  }

  /// Resolve an async dependency.
  Future<T> resolveAsync<T>() async {
    if (_instances.containsKey(T)) {
      return _instances[T] as T;
    }

    if (_asyncCache.containsKey(T)) {
      final instance = await _asyncCache[T]!;
      _instances[T] = instance;
      return instance as T;
    }

    throw Exception("Async dependency of type <$T> is not registered");
  }

  /// Clear all instances and factories.
  void clear() {
    _instances.clear();
    _factories.clear();
    _asyncCache.clear();
  }
}

/// Abstract class for configuration logic.
abstract class DIConfigurator {
  void configure(DIContainer container);
}

/// A function that returns a [DIConfigurator] instance.
typedef ConfigBuilder = DIConfigurator Function();

/// Singleton-based DI registry for global access and bootstrapping.
class DIRegistry {
  static final DIRegistry _instance = DIRegistry._internal();
  factory DIRegistry() => _instance;

  final DIContainer _container = DIContainer();
  bool _isConfigured = false;

  DIRegistry._internal();

  void configure(DIConfigurator configurator) {
    if (_isConfigured) return;
    configurator.configure(_container);
    _isConfigured = true;
  }

  T get<T>() => _container.resolve<T>();
  Future<T> getAsync<T>() => _container.resolveAsync<T>();

  void reset() {
    _container.clear();
    _isConfigured = false;
  }
}
