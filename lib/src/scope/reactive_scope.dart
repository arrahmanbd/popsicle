
part of '../../popsicle.dart';

extension ReactiveScopeX on ReactiveScope {
  bool contains(String key) => _states.containsKey(key);
  List<String> keys() => _states.keys.toList();
}

// Holds Scoped States
class ReactiveScope {
  final Map<String, ReactiveStateBase<dynamic>> _states = {};

  T use<T extends ReactiveStateBase<dynamic>>(String key, T Function() create) {
    if (_states.containsKey(key)) {
      return _states[key] as T;
    }
    final state = create();
    _states[key] = state;
    return state;
  }

  T? get<T>(String key) {
    return _states[key] as T?;
  }

  void dispose(String key) {
    _states[key]?.dispose();
    _states.remove(key);
  }

  void disposeAll() {
    for (final state in _states.values) {
      state.dispose();
    }
    _states.clear();
  }
}
