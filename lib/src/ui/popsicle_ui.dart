part of 'package:popsicle/popsicle.dart';


class PopWidget<T, L extends PopsicleState<T>> extends StatefulWidget {
  /// Factory to create the logic/box
  final L Function() create;

  /// Builder to render UI based on waveform & logic
  final PopsicleBuilderWithLogic<T, L> builder;

  /// Optional middleware
  final List<QuantumMiddleware<T>>? middleware;

  const PopWidget({
    super.key,
    required this.create,
    required this.builder,
    this.middleware,
  });

  @override
  State<PopWidget<T, L>> createState() => _PopWidgetState<T, L>();
}

class _PopWidgetState<T, L extends PopsicleState<T>>
    extends State<PopWidget<T, L>> {
  late final L _logic;
  late T _lastValue;
  late StreamSubscription<T> _subscription;

  @override
  void initState() {
    super.initState();
    _logic = widget.create();

    // Attach middleware if any
    if (widget.middleware != null) {
      for (final mw in widget.middleware!) {
        _logic.use(mw);
      }
    }

    _lastValue = _logic.state;
    _subscription = _logic.field.listen((value) {
      if (mounted) {
        setState(() {
          _lastValue = value;
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    _logic.collapse();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _lastValue, _logic);
  }
}

/// Async version of SchrodingerBox for Future-based state updates
class PopSync<T> extends PopsicleState<T> {
  /// Track the latest active async operation
  Future<T>? _activeFuture;
  bool _isLoading = false;

  PopSync({required super.state});

  /// Whether the box is currently processing an async task
  bool get isLoading => _isLoading;

  /// Run an async task and automatically update waveform when done
  /// Emits signals during the lifecycle: `fluctuate` -> `emit` / `decohere`
  void runAsync(
    Future<T> Function() asyncTask, {
    PopsicleSignal startSignal = PopsicleSignal.refresh,
    PopsicleSignal? completeSignal,
    PopsicleSignal? errorSignal,
    void Function(Object error)? onError,
  }) {
    if (!canEmit) return;

    _isLoading = true;
    emitWithSignal(startSignal);

    final future = asyncTask();
    _activeFuture = future;

    future
        .then((result) {
          if (!canEmit) return;
          // Only update if this is the latest future
          if (_activeFuture == future) {
            shift(result, signal: completeSignal ?? PopsicleSignal.emit);
            _isLoading = false;
          }
        })
        .catchError((error) {
          _isLoading = false;
          emitWithSignal(errorSignal ?? PopsicleSignal.end);
          if (onError != null) onError(error);
        });
  }

  /// Cancel the current active async task
  /// Note: Dart Futures cannot be forcibly cancelled, but this ignores old results
  void cancelAsync() {
    _activeFuture = null;
    _isLoading = false;
    emitWithSignal(PopsicleSignal.end);
  }
}

class PopStream<T> extends PopsicleState<T> {
  PopStream({required super.state});

  @override
  void attachStream(
    Stream<T> stream, {
    PopsicleSignal signal = PopsicleSignal.refresh,
  }) {
    stream.listen((value) {
      shift(value);
    });
  }
}
