part of '../../popsicle.dart';
/// Reactive Provider (Manages States Globally or by Scope)
class ReactiveProvider {
  static final Map<String, ReactiveStateBase<dynamic>> _globalStates = {};
  static final Map<String, Map<String, ReactiveStateBase<dynamic>>> _scopedStates = {};

  // Create a global notifier
  static ReactiveState<T> createNotifier<T>(String key, T initialValue) {
    if (_globalStates.containsKey(key)) {
      return _globalStates[key] as ReactiveState<T>;
    }
    final state = ReactiveState<T>(initialValue);
    _globalStates[key] = state;
    return state;
  }

  // Create a scoped notifier (optional)
  static ReactiveState<T> createScoped<T>(String key, String scope, T initialValue) {
    final scoped = _scopedStates.putIfAbsent(scope, () => {});
    if (scoped.containsKey(key)) {
      return scoped[key] as ReactiveState<T>;
    }
    final state = ReactiveState<T>(initialValue);
    scoped[key] = state;
    return state;
  }

  // Create stream state
  static StreamState<T> createStream<T>(String key, T initialValue) {
    if (_globalStates.containsKey(key)) {
      return _globalStates[key] as StreamState<T>;
    }
    final state = StreamState<T>(initialValue);
    _globalStates[key] = state;
    return state;
  }

  // Create async state
  static AsyncNotifierState<T> createAsync<T>(
    String key,
    Future<T> Function() asyncFunction,
  ) {
    if (_globalStates.containsKey(key)) {
      return _globalStates[key] as AsyncNotifierState<T>;
    }
    final state = AsyncNotifierState<T>(asyncFunction);
    _globalStates[key] = state;
    return state;
  }

  // Get any state (global)
  static ReactiveStateBase<T>? get<T>(String key) {
    return _globalStates[key] as ReactiveStateBase<T>?;
  }

  // Get scoped state
  static ReactiveStateBase<T>? getScoped<T>(String key, String scope) {
    return _scopedStates[scope]?[key] as ReactiveStateBase<T>?;
  }

  // Dispose a global state
  static void dispose(String key) {
    _globalStates[key]?.dispose();
    _globalStates.remove(key);
  }

  // Dispose all states in a scope
  static void disposeScope(String scope) {
    final scoped = _scopedStates.remove(scope);
    if (scoped != null) {
      for (final state in scoped.values) {
        state.dispose();
      }
    }
  }

  // Dispose everything
  static void disposeAll() {
    for (final state in _globalStates.values) {
      state.dispose();
    }
    _globalStates.clear();
    for (final scoped in _scopedStates.values) {
      for (final state in scoped.values) {
        state.dispose();
      }
    }
    _scopedStates.clear();
  }
}


/// ReactiveProvider.disposeScope('profile');
/// ReactiveProvider.disposeAll();
/// final profileCounter = ReactiveProvider.createScoped<int>('counter', 'profile', 0);
// final counter = ReactiveProvider.createNotifier<int>('counter', 0);
