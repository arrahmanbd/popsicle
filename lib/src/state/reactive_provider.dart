part of '../../popsicle.dart';

/// Reactive Provider (Manages States Globally or by Scope)
class ReactiveProvider {
  static final Map<String, ReactiveStateBase<dynamic>> _globalStates = {};
  static final Map<String, Map<String, ReactiveStateBase<dynamic>>>
  _scopedStates = {};

  static bool _debug = false;

  /// Toggle debug logs
  static void enableDebug([bool value = true]) => _debug = value;

  /// Logs only if debug is enabled
  static void _log(String msg) {
    if (_debug) print('[ReactiveProvider] $msg');
  }

  // Get the global state using the key
  static ReactiveStateBase<T>? get<T>(String key) {
    return _globalStates[key] as ReactiveStateBase<T>?;
  }

  /// Create a global ReactiveState<T>
  static ReactiveState<T> createNotifier<T>(T initialValue, {String? key}) {
    // If the key is provided, check for existing state
    if (key != null) {
      final existing = _globalStates[key];
      if (existing != null) {
        if (existing is! ReactiveState<T>) {
          throw Exception('State type mismatch for key: $key');
        }
        return existing;
      }
    }

    // If no key is provided, just create a new state with no key attached
    final state = ReactiveState<T>(initialValue, key: key);
    if (key != null) {
      _globalStates[key] = state;
      _log('Created global notifier [$key]');
    } else {
      _log('Created global notifier (no key)');
    }

    return state;
  }

  /// Create a scoped ReactiveState<T>
  static ReactiveState<T> createScoped<T>(
    String key,
    String scope,
    T initialValue,
  ) {
    final scoped = _scopedStates.putIfAbsent(scope, () => {});
    final existing = scoped[key];

    if (existing != null) {
      if (existing is! ReactiveState<T>) {
        throw Exception('Scoped state type mismatch for [$scope:$key]');
      }
      return existing;
    }

    final state = ReactiveState<T>(initialValue);
    scoped[key] = state;
    _log('Created scoped notifier [$scope:$key]');
    return state;
  }

  /// Create a global StreamState<T>
  static StreamState<T> createStream<T>(String key, T initialValue) {
    final existing = _globalStates[key];
    if (existing != null) {
      if (existing is! StreamState<T>) {
        throw Exception('Stream state type mismatch for key: $key');
      }
      return existing;
    }

    final state = StreamState<T>(initialValue);
    _globalStates[key] = state;
    _log('Created stream state [$key]');
    return state;
  }

  /// Create a global AsyncNotifierState<T>
  static AsyncNotifierState<T> createAsync<T>(
    String key,
    Future<T> Function() asyncFunction,
  ) {
    final existing = _globalStates[key];
    if (existing != null) {
      if (existing is! AsyncNotifierState<T>) {
        throw Exception('Async state type mismatch for key: $key');
      }
      return existing;
    }

    final state = AsyncNotifierState<T>(asyncFunction);
    _globalStates[key] = state;
    _log('Created async state [$key]');
    return state;
  }

  /// Get any scoped state
  static ReactiveStateBase<T>? getScoped<T>(String key, String scope) {
    final state = _scopedStates[scope]?[key];
    if (state is ReactiveStateBase<T>) return state;
    return null;
  }

  /// Dispose global state
  static void dispose(String key) {
    _globalStates.remove(key)?.dispose();
    _log('Disposed global state [$key]');
  }

  /// Dispose all scoped states under a scope
  static void disposeScope(String scope) {
    final scoped = _scopedStates.remove(scope);
    if (scoped != null) {
      for (final state in scoped.values) {
        state.dispose();
      }
      _log('Disposed scope [$scope]');
    }
  }

  /// Dispose all global and scoped states
  static void disposeAll() {
    for (final state in _globalStates.values) {
      state.dispose();
    }
    _globalStates.clear();

    for (final scope in _scopedStates.values) {
      for (final state in scope.values) {
        state.dispose();
      }
    }
    _scopedStates.clear();

    _log('Disposed all states');
  }

  /// Dispose all global states of type T
  static void disposeByType<T>() {
    final keysToRemove = <String>[];
    _globalStates.forEach((key, state) {
      if (state is T) {
        state.dispose();
        keysToRemove.add(key);
      }
    });
    for (final key in keysToRemove) {
      _globalStates.remove(key);
    }
    _log('Disposed states of type $T');
  }
}

/// ReactiveProvider.disposeScope('profile');
/// ReactiveProvider.disposeAll();
/// final profileCounter = ReactiveProvider.createScoped<int>('counter', 'profile', 0);
// final counter = ReactiveProvider.createNotifier<int>('counter', 0);
