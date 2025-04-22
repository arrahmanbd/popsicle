part of '../../popsicle.dart';

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

/// StreamState Model (for continuous updates)
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

/// AsyncNotifierState (for Future-based state)
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
      String errorMessage = 'An error occurred';
      if (e is TimeoutException) {
        errorMessage = 'Request timed out. Please try again later.';
      } else if (e is SocketException) {
        errorMessage = 'No internet connection.';
      } else {
        errorMessage = e.toString();
      }
      _notifier.value = AsyncState.error(errorMessage);
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
          return onLoading(); // Show loading state
        } else if (state.error != null) {
          return onError(state.error!); // Show error state
        } else if (state.data != null) {
          return onSuccess(state.data as T); // Show success state
        } else {
          return const SizedBox(); // Return nothing if no state is available
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
          // Safe cast with null check
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
