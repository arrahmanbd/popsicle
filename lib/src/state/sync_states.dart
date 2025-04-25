part of '../../popsicle.dart';

/// Async State Model (loading, success, error)
class AsyncState<T> {
  final T? data;
  final String? error;
  final bool isLoading;

  const AsyncState._({this.data, this.error, required this.isLoading});

  factory AsyncState.loading() => const AsyncState._(isLoading: true);
  factory AsyncState.success(T data) =>
      AsyncState._(data: data, isLoading: false);
  factory AsyncState.error(String error) =>
      AsyncState._(error: error, isLoading: false);
}

/// StreamState Model (for continuous updates)
class StreamState<T> extends ReactiveStateBase<T> {
  final StreamController<T> _controller = StreamController<T>.broadcast();
  late T _currentValue;
  final List<void Function(T)> _listeners = [];

  StreamState(T initialValue) {
    _currentValue = initialValue;
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
    for (var listener in _listeners) {
      listener(newValue);
    }
  }

  @override
  void dispose() {
    _controller.close();
  }

  Stream<T> get stream => _controller.stream;

  void addListener(void Function(T) listener) {
    _listeners.add(listener);
  }

  void removeListener(void Function(T) listener) {
    _listeners.remove(listener);
  }
}

/// AsyncNotifierState (for Future-based state)
class AsyncNotifierState<T> extends ReactiveStateBase<AsyncState<T>> {
  final Future<T> Function() asyncFunction;
  final ValueNotifier<AsyncState<T>> _notifier = ValueNotifier(
    AsyncState.loading(),
  );
  Completer<void>? _activeRequest;

  AsyncNotifierState(this.asyncFunction) {
    refresh();
  }

  Future<void> refresh() async {
    if (_activeRequest != null && !_activeRequest!.isCompleted) return;
    _activeRequest = Completer<void>();
    _notifier.value = AsyncState.loading();
    try {
      final result = await asyncFunction();
      _notifier.value = AsyncState.success(result);
      _activeRequest!.complete();
    } catch (e) {
      String errorMessage = _parseError(e);
      _notifier.value = AsyncState.error(errorMessage);
      _activeRequest!.completeError(e);
    }
  }

  String _parseError(Object e) {
    if (e is TimeoutException) {
      return 'Request timed out. Please try again later.';
    } else if (e is SocketException) {
      return 'No internet connection.';
    }
    return e.toString();
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

/// Extensions for handling AsyncNotifierState
extension StateHandlingExtension<T> on AsyncNotifierState<T> {
  Widget listen({
    required Widget Function(T data) onSuccess,
    required Widget Function(String error) onError,
    required Widget Function() onLoading,
  }) {
    return ValueListenableBuilder<AsyncState<T>>(
      valueListenable: listenable,
      builder: (_, state, __) {
        if (state.isLoading) {
          return onLoading();
        } else if (state.error != null) {
          return onError(state.error!);
        } else if (state.data != null) {
          return onSuccess(state.data as T);
        } else {
          return const SizedBox();
        }
      },
    );
  }
}

/// Extensions for handling StreamState
extension StreamStateHandlingExtension<T> on StreamState<T> {
  Widget listen({
    required Widget Function(T data) onSuccess,
    required Widget Function(String error) onError,
    required Widget Function() onLoading,
  }) {
    return StreamBuilder<T>(
      stream: stream,
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return onLoading();
        } else if (snapshot.hasError) {
          return onError(snapshot.error.toString());
        } else if (snapshot.hasData) {
          final data = snapshot.data;
          if (data != null) {
            return onSuccess(data);
          }
        }
        return const SizedBox();
      },
    );
  }
}
