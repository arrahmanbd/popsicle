part of '../../popsicle.dart';

/// Enum to distinguish between factory and singleton.
enum _EntryType { factory, singleton }

/// Internal storage for dependency entries.
class _DIEntry {
  final Function factory;
  final _EntryType type;

  _DIEntry(this.factory, this.type);
}

class DIContainer {
  final Map<_DIKey, _DIEntry> _factories = {};
  final Map<_DIKey, dynamic> _instances = {};
  final Map<_DIKey, Future<dynamic>> _asyncCache = {};

  void registerFactory<T>(T Function() factory, {String? id}) {
    _factories[_DIKey(T, id)] = _DIEntry(factory, _EntryType.factory);
  }

  void registerSingleton<T>(T instance, {String? id}) {
    _instances[_DIKey(T, id)] = instance;
  }

  void registerSingletonLazy<T>(T Function() lazyFactory, {String? id}) {
    registerFactory<T>(() {
      final instance = lazyFactory();
      registerSingleton<T>(instance, id: id);
      return instance;
    }, id: id);
  }

  void registerAsyncSingleton<T>(Future<T> Function() factory, {String? id}) {
    _asyncCache[_DIKey(T, id)] = factory();
  }

  T resolve<T>({String? id}) {
    final key = _DIKey(T, id);

    if (_instances.containsKey(key)) {
      return _instances[key] as T;
    }

    if (_factories.containsKey(key)) {
      final entry = _factories[key]!;
      final instance = entry.factory();
      if (entry.type == _EntryType.singleton) {
        _instances[key] = instance;
      }
      return instance as T;
    }

    throw Exception("Dependency of type <$T> (id: $id) is not registered");
  }

  Future<T> resolveAsync<T>({String? id}) async {
    final key = _DIKey(T, id);

    if (_instances.containsKey(key)) {
      return _instances[key] as T;
    }

    if (_asyncCache.containsKey(key)) {
      final instance = await _asyncCache[key]!;
      _instances[key] = instance;
      return instance as T;
    }

    throw Exception("Async dependency of type <$T> (id: $id) is not registered");
  }

  void clear() {
    _instances.clear();
    _factories.clear();
    _asyncCache.clear();
  }
}

/// Small helper class for type+id based key
class _DIKey {
  final Type type;
  final String? id;

  _DIKey(this.type, this.id);

  @override
  bool operator ==(Object other) {
    return other is _DIKey && other.type == type && other.id == id;
  }

  @override
  int get hashCode => type.hashCode ^ (id?.hashCode ?? 0);
}
