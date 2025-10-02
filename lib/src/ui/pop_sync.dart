part of 'package:popsicle/popsicle.dart';

/// A Logic class designed for async tasks.
/// Handles loading, error, and cancellation states in a professional way.
class PopSync<T> extends Logic<T> {
  Future<T>? _activeFuture;
  bool _isLoading = false;
  Object? _lastError;

  PopSync(super.state);

  bool get isLoading => _isLoading;
  Object? get lastError => _lastError;

  /// Run an async task safely.
  void runAsync(
    Future<T> Function() task, {
    PopsicleSignal startSignal = PopsicleSignal.refresh,
    PopsicleSignal? completeSignal,
    PopsicleSignal? errorSignal,
    void Function(Object error, StackTrace stack)? onError,
  }) {
    if (!canEmit) return;

    _isLoading = true;
    _lastError = null;
    emitWithSignal(startSignal);

    final future = task();
    _activeFuture = future;

    future.then((result) {
      if (!canEmit || _activeFuture != future) return;

      if (result != state) {
        shift(result, signal: completeSignal ?? PopsicleSignal.emit);
      } else {
        emitWithSignal(completeSignal ?? PopsicleSignal.emit);
      }

      _isLoading = false;
    }).catchError((error, stack) {
      if (!canEmit || _activeFuture != future) return;

      _isLoading = false;
      _lastError = error;
      emitWithSignal(errorSignal ?? PopsicleSignal.done);

      if (onError != null) {
        onError(error, stack);
      } else {
        debugPrint('⚠️ PopSync error: $error');
      }
    });
  }

  /// Cancel any in-progress task
  void cancelAsync() {
    _activeFuture = null;
    _isLoading = false;
    _lastError = null;
    emitWithSignal(PopsicleSignal.done);
  }

  @override
  void collapse() {
    cancelAsync();
    super.collapse();
  }
}

/// A Logic class designed for streaming data.
/// Provides automatic subscription cleanup.
class PopStream<T> extends Logic<T> {
  final List<StreamSubscription> _subs = [];

  PopStream(super.state);

  /// Attach a stream and forward values into this logic.
  void attachStream(
    Stream<T> stream, {
    PopsicleSignal signal = PopsicleSignal.refresh,
  }) {
    final sub = stream.listen(
      (value) => shift(value, signal: signal),
      onError: (error) => debugPrint('⚠️ PopStream error: $error'),
    );
    _subs.add(sub);
  }

  @override
  void collapse() {
    for (final sub in _subs) {
      sub.cancel();
    }
    _subs.clear();
    super.collapse();
  }
}

