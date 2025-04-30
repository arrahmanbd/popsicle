part of '../../popsicle.dart';

/// In a real implementation, this would handle the actual dependency storage and resolution.
class DI {
  final Map<String, dynamic> _singletons = {};
  final Map<String, dynamic Function()> _factories = {};
  final Map<String, dynamic Function()> _lazySingletons = {};
  final Set<String> _resolving = {};

  void registerSingleton<T>(T instance, {String? id}) {
    _singletons[_key<T>(id)] = instance;
  }

  void registerFactory<T>(T Function() factory, {String? id}) {
    _factories[_key<T>(id)] = factory;
  }

  void registerLazySingleton<T>(T Function() factory, {String? id}) {
    _lazySingletons[_key<T>(id)] = factory;
  }

  T resolve<T>({String? id}) {
    final key = _key<T>(id);
    if (_resolving.contains(key)) {
      throw DependencyCycleException('Cycle detected for $key');
    }
    _resolving.add(key);
    if (_singletons.containsKey(key)) {
      return _singletons[key] as T;
    }
    if (_lazySingletons.containsKey(key)) {
      final instance = _lazySingletons[key]!();
      _singletons[key] = instance;
      _lazySingletons.remove(key);
      return instance as T;
    }
    if (_factories.containsKey(key)) {
      return _factories[key]!() as T;
    }
    throw DependencyNotFoundException(
      'No dependency registered for type $T with id $id',
    );
  }

  Future<T> resolveAsync<T>({String? id}) async {
    // Simulate async resolution
    return resolve<T>(id: id);
  }

  void clear() {
    _singletons.clear();
    _factories.clear();
    _lazySingletons.clear();
  }

  bool isRegistered<T>({String? id}) {
    final key = _key<T>(id);
    return _singletons.containsKey(key) ||
        _factories.containsKey(key) ||
        _lazySingletons.containsKey(key);
  }

  String _key<T>(String? id) => id != null ? '$T:$id' : T.toString();
}
