part of 'package:popsicle/popsicle.dart';

/// 🟢 Generic reactive widget for _BasePopsicleState

/// Generic builder for Popsicle states (like Riverpod Consumer)
// ignore: library_private_types_in_public_api

// ignore: library_private_types_in_public_api
class PopWidget<T, L extends _BasePopsicleState<T>> extends StatefulWidget {
  /// Factory to create the logic
  final L Function() create;

  /// UI builder with the logic and current state
  final PopsicleBuilderWithLogic<T, L> builder;

  /// Optional middleware
  final List<PopsicleMiddleware<T>>? middleware;

  /// If true, the logic will be kept alive and cached across widget rebuilds
  final bool keepAlive;

  const PopWidget({
    super.key,
    required this.create,
    required this.builder,
    this.middleware,
    this.keepAlive = true, // default true
  });

  @override
  State<PopWidget<T, L>> createState() => _PopWidgetState<T, L>();
}

class _PopWidgetState<T, L extends _BasePopsicleState<T>>
    extends State<PopWidget<T, L>>
    with AutomaticKeepAliveClientMixin {
  /// Cache per //[] type
  static final Map<Type, _BasePopsicleState> _logicCache = {};

  late final L _logic;
  late T _lastValue;
  late StreamSubscription<T> _subscription;

  bool _middlewareAttached = false;

  @override
  void initState() {
    super.initState();

    // Use cache or create new
    if (widget.keepAlive && _logicCache.containsKey(L)) {
      _logic = _logicCache[L]! as L;
    } else {
      _logic = widget.create();
      if (widget.keepAlive) {
        _logicCache[L] = _logic;
      }
    }

    // Attach middleware only once per logic instance
    if (!_middlewareAttached && widget.middleware != null) {
      for (final m in widget.middleware!) {
        _logic.use(m);
      }
      _middlewareAttached = true;
    }

    // Initial value
    _lastValue = _logic.state;

    // Subscribe to updates
    _subscription = _logic.field.listen(
      (value) {
        if (!mounted) return;
        setState(() => _lastValue = value);
      },
      onError: (error) {
        // optional: handle error here
      },
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    if (!widget.keepAlive) {
      _logic.collapse();
      _logicCache.remove(L);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // keep alive
    return widget.builder(context, _lastValue, _logic);
  }

  @override
  bool get wantKeepAlive => widget.keepAlive;
}

/// 🟢 Async-enabled _BasePopsicleState
class PopSync<T> extends Logic<T> {
  Future<T>? _activeFuture;
  bool _isLoading = false;
  Object? _lastError;

  PopSync(super.state);

  bool get isLoading => _isLoading;
  Object? get lastError => _lastError;

  void runAsync(
    Future<T> Function() asyncTask, {
    PopsicleSignal startSignal = PopsicleSignal.refresh,
    PopsicleSignal? completeSignal,
    PopsicleSignal? errorSignal,
    void Function(Object error)? onError,
  }) {
    if (!canEmit) return;

    _isLoading = true;
    _lastError = null;
    emitWithSignal(startSignal);

    final future = asyncTask();
    _activeFuture = future;

    future
        .then((result) {
          if (!canEmit || _activeFuture != future) return;
          // Don’t shift if value hasn’t changed
          if (result != state) {
            shift(result, signal: completeSignal ?? PopsicleSignal.emit);
          } else {
            emitWithSignal(completeSignal ?? PopsicleSignal.emit);
          }
          _isLoading = false;
        })
        .catchError((error) {
          if (!canEmit || _activeFuture != future) return;
          _isLoading = false;
          _lastError = error;
          emitWithSignal(errorSignal ?? PopsicleSignal.done);
          if (onError != null) onError(error);
        });
  }

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

/// 🟢 Stream-enabled _BasePopsicleState
class PopStream<T> extends Logic<T> {
  PopStream(super.state);
  @override
  void attachStream(
    Stream<T> stream, {
    PopsicleSignal signal = PopsicleSignal.refresh,
  }) {
    final sub = stream.listen((value) {
      shift(value, signal: signal);
    });
    _subscriptions.add(sub);
  }
}
