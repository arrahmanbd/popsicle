 part of '../../popsicle.dart';

/// Base class for state management
abstract class ReactiveStateBase<T> {
  T get value;
  void update(T newValue);
  void dispose();
  void onInit() {}
  void onDispose() {}
}


/// NotifierState (for reactive state with middleware)
class ReactiveState<T> extends ReactiveStateBase<T> {
  final ValueNotifier<T> _notifier;
  final List<void Function(T)> _listeners = [];
  final Future<T> Function()? _persistenceLoader;
  final MiddlewarePipeline<T> _middlewarePipeline = MiddlewarePipeline<T>();
  final String? _key;
  final String? _scope;

  ReactiveState(
    T initialValue, {
    Future<T> Function()? persistenceLoader,
    String? key,
    String? scope,
  })  : _notifier = ValueNotifier(initialValue),
        _persistenceLoader = persistenceLoader,
        _key = key,
        _scope = scope {
    onInit();
    _loadPersistedState();
  }

  @override
  T get value => _notifier.value;

  @override
  void update(T newValue) {
    final modifiedValue = _middlewarePipeline.apply(
      MiddlewareContext(
        oldValue: value,
        newValue: newValue,
        key: _key,
        scope: _scope,
      ),
    );
    _notifier.value = modifiedValue;
    for (var listener in _listeners) {
      listener(modifiedValue);
    }
  }

  @override
  void dispose() {
    onDispose();
    _notifier.dispose();
  }

  void addListener(void Function(T) listener) {
    _listeners.add(listener);
  }

  void removeListener(void Function(T) listener) {
    _listeners.remove(listener);
  }

  void addMiddleware(Middleware<T> middleware) {
    _middlewarePipeline.add(middleware);
  }

  ValueListenable<T> get listenable => _notifier;

  Future<void> _loadPersistedState() async {
    if (_persistenceLoader != null) {
      try {
        final persisted = await _persistenceLoader!();
        _notifier.value = persisted;
      } catch (_) {}
    }
  }
}

extension NotifierExtensions<T> on ReactiveState<T> {
  Widget listen(Widget Function(T value) builder) {
    return ValueListenableBuilder<T>(
      valueListenable: _notifier,
      builder: (_, value, __) => builder(value),
    );
  }
}


/// Computed reactive state
class ComputedState<T> extends ReactiveStateBase<T> {
  final List<ReactiveStateBase> dependencies;
  final T Function() compute;
  late final VoidCallback _listener;
  late T _value;

  ComputedState(this.dependencies, this.compute) {
    _value = compute();
    _listener = () => update(compute());
    for (var dep in dependencies) {
      if (dep is ReactiveState) {
        dep.addListener((_) => _listener());
      }
    }
  }

  @override
  T get value => _value;

  @override
  void update(T newValue) {
    _value = newValue;
  }

  @override
  void dispose() {
    for (var dep in dependencies) {
      if (dep is ReactiveState) {
        dep.removeListener((_) => _listener());
      }
    }
  }
}