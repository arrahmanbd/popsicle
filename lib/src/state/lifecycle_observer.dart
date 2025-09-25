part of 'package:popsicle/popsicle.dart';

/// 🍭 **PopsicleObserver** — Reactively watches a PopsicleState (waveform).
///
/// This widget listens to a PopsicleState and rebuilds when the flavor (state)
/// or signal changes. It's like having a straw in the popsicle — you can taste it
/// without altering it.
///
/// - `builder` — called when the state updates (flavor changed)
/// - `builderWithSignal` — called when both state and signal update
///
/// Example:
/// ```dart
/// PopsicleObserver<int>(
///   waveform: counter,
///   builder: (context, value) => Text('Counter: $value'),
///   builderWithSignal: (context, value, signal) {
///     print('Signal: $signal');
///     return Text('Counter: $value');
///   },
/// )
/// ```
class PopsicleObserver<T> extends StatefulWidget {
  // ignore: library_private_types_in_public_api
  final _BasePopsicleState<T> state;
  final PopsicleBuilder<T> builder;
  final PopsicleBuilderWithEntangle<T>? builderWithSignal;

  const PopsicleObserver({
    super.key,
    required this.state,
    required this.builder,
    this.builderWithSignal,
  });

  @override
  State<PopsicleObserver<T>> createState() => _PopsicleObserverState<T>();
}

class _PopsicleObserverState<T> extends State<PopsicleObserver<T>> {
  late T _lastWaveValue;
  // ignore: unused_field
  late PopsicleSignal _signal;
  StreamSubscription<T>? _subscription;

  @override
  void initState() {
    super.initState();
    _initSubscription(widget.state);
  }

  @override
  void didUpdateWidget(covariant PopsicleObserver<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _subscription?.cancel();
      _initSubscription(widget.state);
    }
  }

  void _initSubscription(_BasePopsicleState<T> waveform) {
    _lastWaveValue = waveform.state;
    _signal = waveform.currentSignal;
    _subscription = waveform.field.listen((data) {
      if (mounted) {
        setState(() {
          _lastWaveValue = data;
          _signal = waveform.currentSignal;
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    // 🚫 Don't call waveform.collapse() here
    // because this widget is only an observer, not the owner.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _lastWaveValue);
  }
}

/// Owns a [_BasePopsicleState] and disposes it automatically when the widget is removed.
///
/// Use when the lifecycle of the waveform should be tied to the widget tree.
class PopsicleProvider<T> extends StatefulWidget {
  // ignore: library_private_types_in_public_api
  final _BasePopsicleState<T> Function() create;
  final Widget Function(BuildContext, _BasePopsicleState<T>) builder;

  const PopsicleProvider({
    super.key,
    required this.create,
    required this.builder,
  });

  @override
  State<PopsicleProvider<T>> createState() => _PopsicleProviderState<T>();
}

class _PopsicleProviderState<T> extends State<PopsicleProvider<T>> {
  late final _BasePopsicleState<T> _waveform;

  @override
  void initState() {
    super.initState();
    _waveform = widget.create();
  }

  @override
  void dispose() {
    _waveform.collapse(); // Dispose automatically
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _waveform);
  }
}

// ignore: library_private_types_in_public_api
class LogicProvider<T, L extends _BasePopsicleState<T>> extends StatefulWidget {
  final L Function() create;
  final Widget Function(BuildContext context, L logic) builder;

  /// Optional middleware to attach immediately
  final List<PopsicleMiddleware<T>>? middleware;

  const LogicProvider({
    super.key,
    required this.create,
    required this.builder,
    this.middleware,
  });

  @override
  State<LogicProvider<T, L>> createState() => _LogicProviderState<T, L>();
}

class _LogicProviderState<T, L extends _BasePopsicleState<T>>
    extends State<LogicProvider<T, L>> {
  late final L _logic;

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
  }

  @override
  void dispose() {
    _logic.collapse();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _logic);
  }
}
