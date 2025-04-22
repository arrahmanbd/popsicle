part of '../../popsicle.dart';

/// Base class for state management
abstract class ReactiveStateBase<T> {
  T get value;
  void update(T newValue);
  void dispose();
}

/// NotifierState (for reactive state with middleware)
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

  Future<void> _loadPersistedState() async {
    if (_persistenceLoader != null) {
    
    }
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
