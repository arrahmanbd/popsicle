part of '../../popsicle.dart';

/// Base class for state management
abstract class ReactiveStateBase<T> {
  T get value;
  void update(T newValue);
  void dispose();
}

/// NotifierState (for simple reactive state with middleware)
class ReactiveState<T> extends ReactiveStateBase<T> {
  final ValueNotifier<T> _notifier;
  final List<void Function(T)> _listeners = [];
  final Future<T> Function()? _persistenceLoader;
  final MiddlewarePipeline<T> _middlewarePipeline = MiddlewarePipeline<T>();

  ReactiveState(T initialValue, {Future<T> Function()? persistenceLoader})
    : _notifier = ValueNotifier(initialValue),
      _persistenceLoader = persistenceLoader {
    _loadPersistedState();
  }

  @override
  T get value => _notifier.value;

  @override
  void update(T newValue) {
    ///  Updates state, but applies middleware first
    final modifiedValue = _middlewarePipeline.apply(value, newValue);
    _notifier.value = modifiedValue;
    for (var listener in _listeners) {
      listener(modifiedValue);
    }
    // _persistState(modifiedValue);
  }

  @override
  void dispose() {
    _notifier.dispose();
  }

  void addListener(void Function(T) listener) {
    _listeners.add(listener);
  }

  void removeListener(void Function(T) listener) {
    _listeners.remove(listener);
  }

  /// Add middleware for state updates
  void addMiddleware(Middleware<T> middleware) {
    _middlewarePipeline.add(middleware);
  }

  ValueListenable<T> get listenable => _notifier;

  // will be implimented in the future but not in shared pref
  // Future<void> _persistState(T newValue) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final key = 'state_${T.toString()}';
  //   try {
  //     await prefs.setString(key, jsonEncode(newValue));
  //   } catch (e) {
  //     debugPrint("⚠️ Error persisting state: $e");
  //   }
  // }

  Future<void> _loadPersistedState() async {
    if (_persistenceLoader != null) {
      //final loadedValue = await _persistenceLoader!();
      //_notifier.value = loadedValue;
    }
  }
}

/// StreamState (for continuous updates)
class StreamState<T> extends ReactiveStateBase<T> {
  final StreamController<T> _controller = StreamController.broadcast();
  T _currentValue;

  StreamState(this._currentValue) {
    _controller.add(_currentValue);
  }

  @override
  T get value => _currentValue;

  @override
  void update(T newValue) {
    _currentValue = newValue;
    if (!_controller.isClosed) {
      _controller.add(newValue);
    }
  }

  @override
  void dispose() {
    if (!_controller.isClosed) _controller.close();
  }

  Stream<T> get stream => _controller.stream;
}

///  AsyncNotifierState (for Future-based state)
class AsyncNotifierState<T> extends ReactiveStateBase<AsyncState<T>> {
  final Future<T> Function() asyncFunction;
  final ValueNotifier<AsyncState<T>> _notifier = ValueNotifier(
    AsyncState.loading(),
  );

  AsyncNotifierState(this.asyncFunction) {
    _load();
  }

  Future<void> _load() async {
    try {
      final result = await asyncFunction();
      _notifier.value = AsyncState.success(result);
    } catch (e) {
      _notifier.value = AsyncState.error(e.toString());
    }
  }

  @override
  AsyncState<T> get value => _notifier.value;

  @override
  void update(AsyncState<T> newValue) {
    _notifier.value = newValue;
  }

  @override
  void dispose() {
    _notifier.dispose();
  }

  ValueListenable<AsyncState<T>> get listenable => _notifier;
}

/// Async State Model (loading, success, error)
class AsyncState<T> {
  final T? data;
  final String? error;
  final bool isLoading;

  AsyncState._({this.data, this.error, required this.isLoading});

  factory AsyncState.loading() => AsyncState._(isLoading: true);
  factory AsyncState.success(T data) =>
      AsyncState._(data: data, isLoading: false);
  factory AsyncState.error(String error) =>
      AsyncState._(error: error, isLoading: false);
}

/// Reactive Provider (Manages States)
class ReactiveProvider {
  static final Map<String, ReactiveStateBase<dynamic>> _states = {};

  static ReactiveState<T> createNotifier<T>(String key, T initialValue) {
    if (_states.containsKey(key)) {
      return _states[key] as ReactiveState<T>;
    }
    final state = ReactiveState<T>(initialValue);
    _states[key] = state;
    return state;
  }

  static StreamState<T> createStream<T>(String key, T initialValue) {
    if (_states.containsKey(key)) {
      return _states[key] as StreamState<T>;
    }
    final state = StreamState<T>(initialValue);
    _states[key] = state;
    return state;
  }

  static AsyncNotifierState<T> createAsync<T>(
    String key,
    Future<T> Function() asyncFunction,
  ) {
    if (_states.containsKey(key)) {
      return _states[key] as AsyncNotifierState<T>;
    }
    final state = AsyncNotifierState<T>(asyncFunction);
    _states[key] = state;
    return state;
  }

  static ReactiveStateBase<T>? get<T>(String key) {
    return _states[key] as ReactiveStateBase<T>?;
  }

  static void dispose(String key) {
    _states[key]?.dispose();
    _states.remove(key);
  }
}

/// Extension to simplify UI updates for NotifierState
extension NotifierExtensions<T> on ReactiveState<T> {
  Widget listen(Widget Function(T value) builder) {
    return ValueListenableBuilder<T>(
      valueListenable: _notifier,
      builder: (_, value, __) => builder(value),
    );
  }
}
