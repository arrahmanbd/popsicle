part of 'package:popsicle/popsicle.dart';

/// A professional state-aware widget that binds a [Logic] instance
/// to the widget tree, rebuilds on state changes, and supports middleware.
// ignore: library_private_types_in_public_api
class PopWidget<T, L extends _BasePopsicleState<T>> extends StatefulWidget {
  /// Factory to create or resolve the logic.
  final L Function() create;

  /// UI builder that exposes the [logic] and current [state].
  final PopsicleBuilderWithLogic<T, L> builder;

  /// Middleware list, executed in order, transforming state updates.
  final List<PopsicleMiddleware<T>>? middleware;

  /// If true, the logic instance is cached and reused across rebuilds.
  final bool keepAlive;

  const PopWidget({
    super.key,
    required this.create,
    required this.builder,
    this.middleware,
    this.keepAlive = true,
  });

  @override
  State<PopWidget<T, L>> createState() => _PopWidgetState<T, L>();
}

class _PopWidgetState<T, L extends _BasePopsicleState<T>>
    extends State<PopWidget<T, L>> with AutomaticKeepAliveClientMixin {
  /// Cache per Logic type when `keepAlive` is enabled.
  static final Map<Type, _BasePopsicleState> _logicCache = {};

  late final L _logic;
  late T _lastValue;
  StreamSubscription<T>? _subscription;

  bool _middlewareAttached = false;

  @override
  void initState() {
    super.initState();

    // Resolve from cache or create new
    if (widget.keepAlive && _logicCache.containsKey(L)) {
      _logic = _logicCache[L]! as L;
    } else {
      _logic = widget.create();
      if (widget.keepAlive) {
        _logicCache[L] = _logic;
      }
    }

    // Attach middleware once per instance
    if (!_middlewareAttached && widget.middleware != null) {
      for (final m in widget.middleware!) {
        _logic.use(m);
      }
      _middlewareAttached = true;
    }

    // Initial snapshot
    _lastValue = _logic.state;

    // Subscribe to updates
    _subscription = _logic.field.listen(
      (value) {
        if (!mounted) return;
        setState(() => _lastValue = value);
      },
      onError: (error, stack) {
        debugPrint('⚠️ PopWidget encountered error: $error');
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    if (!widget.keepAlive) {
      _logic.collapse();
      _logicCache.remove(L);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // maintain keepAlive contract
    return widget.builder(context, _lastValue, _logic);
  }

  @override
  bool get wantKeepAlive => widget.keepAlive;
}

