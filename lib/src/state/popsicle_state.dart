part of 'package:popsicle/popsicle.dart';

/// 🍭 **PopsicleState** — Your sweet, reactive state container.
///
/// Imagine holding a popsicle:
/// - You can **lick** it (observe its state)
/// - You can **bite** it (update the state)
/// - You can **freeze** it (make it read-only)
/// - You can **melt** it (collapse and clean up)
///
/// PopsicleState broadcasts updates to everyone enjoying the same treat,
/// keeping your app state fresh, reactive, and easy to share.
///
/// ### Features
/// - 🍦 **shift**: Bite into the popsicle (update state)
/// - 🍓 **resonate**: Re-share the flavor without changing it
/// - 🍪 **emitWithSignal**: Send signals like `refresh` or `done`
/// - 🧊 **restrictObservation**: Freeze the popsicle (read-only)
/// - 🌊 **attachStream**: Drip in values from a stream
/// - 🔥 **collapse**: Melt it completely when finished
///
/// ### Example — Counter
/// ```dart
/// final counter = PopsicleState<int>(state: 0);
/// counter.field.listen((value) => print('Counter: $value'));
/// counter.shift(1); // 🍦 Counter: 1
/// counter.shift(2); // 🍦 Counter: 2
/// counter.resonate(); // 🍓 Counter: 2
/// ```
///
/// ### Example — With Signals
/// ```dart
/// counter.emitWithSignal(PopsicleSignal.refresh, newState: 10);
// UI reacts depending on the signal type
/// ```
///
/// ### Example — Read-Only
/// ```dart
/// final frozenCounter = counter.restrictObservation();
/// frozenCounter.field.listen((value) => print('Counter: $value'));
/// frozenCounter.shift(42); // ❌ Throws PopsicleMelted
/// ```

abstract class Logic<T> extends _BasePopsicleState<T> {
  Logic(T state) : super(state: state);

  /// Static access helper
  // ignore: library_private_types_in_public_api
  static TLogic of<TLogic extends _BasePopsicleState>() =>
      Popsicle.use<TLogic>();
}

abstract class _BasePopsicleState<T> implements Listenable {
  /// 🍦 Current flavor of the popsicle
  T state;

  /// 🍭 Current signal/state of the popsicle
  PopsicleSignal currentSignal;

  /// 🌊 Stream broadcasting flavor changes
  final StreamController<T> _entanglementField =
      StreamController<T>.broadcast();

  /// 👂 Local listeners
  final List<VoidCallback> _listeners = [];

  /// 🧩 Middleware chain to transform updates
  final List<PopsicleMiddleware<T>> _middleware = [];

  /// 📡 Stream subscriptions (auto-cancel on collapse)
  final List<StreamSubscription> _subscriptions = [];

  /// 🔗 Internal observer & entanglement flags
  Function(_BasePopsicleState<T>)? _observer;
  bool _observerEntangled = false;
  bool _canCollapse = true;
  Listenable? _source;

  /// 🧹 Optional dispose callback
  void Function()? onDispose;

  _BasePopsicleState({
    required this.state,
    this.currentSignal = PopsicleSignal.idle,
    this.onDispose,
  });

  // ==============================
  // Middleware
  // ==============================

  void use(PopsicleMiddleware<T> middleware) => _middleware.add(middleware);

  // ==============================
  // State Emission
  // ==============================

  void shift(T newState, {PopsicleSignal signal = PopsicleSignal.emit}) {
    if (!_canCollapse) return;

    T processedState = newState;
    for (final mw in _middleware) {
      final result = mw(state, processedState);
      if (result == null) return;
      processedState = result;
    }

    state = processedState;
    currentSignal = signal;

    if (!_entanglementField.isClosed) _entanglementField.add(processedState);
    _notifyListeners();
  }

  void emitIfChanged(T newState) {
    if (state != newState) shift(newState);
  }

  void resonate() {
    if (!_entanglementField.isClosed) _entanglementField.add(state);
    currentSignal = PopsicleSignal.update;
  }

  void emitWithSignal(PopsicleSignal signal, {T? newState}) {
    if (newState != null && newState != state) {
      shift(newState, signal: signal);
    } else {
      if (!_entanglementField.isClosed) _entanglementField.add(state);
      currentSignal = signal;
    }
  }

  void sendSignal(PopsicleSignal signal) {
    currentSignal = signal;
    if (!_entanglementField.isClosed) _entanglementField.add(state);
  }

  // ==============================
  // Observation / Entanglement
  // ==============================

  bool entangle(Listenable source, Function(_BasePopsicleState<T>) observer) {
    if (!_observerEntangled) {
      _source = source;
      _observer = observer;
      source.addListener(_observe);
      _observerEntangled = true;
      return true;
    }
    return false;
  }

  void _observe() => _observer?.call(this);

  bool disentangle({Function()? decay}) {
    if (_observerEntangled && _source != null) {
      _observerEntangled = false;
      _source?.removeListener(_observe);
      decay?.call();
      _source = null;
      return true;
    }
    return false;
  }

  // ==============================
  // Stream & Async Support
  // ==============================

  void attachStream(
    Stream<T> stream, {
    PopsicleSignal signal = PopsicleSignal.refresh,
  }) {
    final sub = stream.listen((value) {
      if (canEmit) shift(value, signal: signal);
    });
    _subscriptions.add(sub);
  }

  // ==============================
  // Lifecycle / Dispose
  // ==============================

  /// 🔥 Melt the popsicle and clean up
  void collapse() {
    if (!_canCollapse) return;

    _canCollapse = false;

    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();

    _entanglementField.close();
    _source?.removeListener(_observe);

    // Call user-defined dispose
    onDispose?.call();

    _resetQuantumState();
    currentSignal = PopsicleSignal.done;
  }

  void decohere({
    PopsicleSignal signal = PopsicleSignal.idle,
    bool clearObservers = true,
  }) {
    if (clearObservers) {
      _source?.removeListener(_observe);
      _resetQuantumState(signal: signal);
    }
  }

  void _resetQuantumState({PopsicleSignal signal = PopsicleSignal.idle}) {
    currentSignal = signal;
    _source = null;
    _observerEntangled = false;
    _observer = null;
    _middleware.clear();
  }

  // ==============================
  // Listenable Implementation
  // ==============================

  @override
  void addListener(VoidCallback listener) => _listeners.add(listener);

  @override
  void removeListener(VoidCallback listener) => _listeners.remove(listener);

  void _notifyListeners() {
    for (final l in _listeners) l();
  }

  // ==============================
  // Getters
  // ==============================

  Stream<T> get field => _entanglementField.stream;
  bool get canEmit => _canCollapse;
}

/// ❄️ **ReadonlyState** — A frozen popsicle.
///
/// Wraps a [_BasePopsicleState] in a read-only shell.
/// All mutation methods throw [PopsicleMelted], ensuring the popsicle stays frozen.
///
/// Useful for:
/// - Preventing accidental bites (state changes) deep in the widget tree
/// - Maintaining clear separation between controllers and observers
/// - Keeping signals visible while locking the flavor
///
/// Example:
/// ```dart
/// final counter = PopsicleState<int>(state: 0);
/// final frozen = counter.restrictObservation();
/// frozen.field.listen((value) => print('Counter: $value'));
/// frozen.shift(42); // ❌ Throws PopsicleMelted
/// ```
class ReadonlyState<T> extends _BasePopsicleState<T> {
  final _BasePopsicleState<T> _base;

  ReadonlyState(this._base) : super(state: _base.state);

  // ⚠ Forbidden bites
  @override
  void shift(T newState, {PopsicleSignal signal = PopsicleSignal.emit}) =>
      throw PopsicleMelted("shift($newState, $signal)");

  @override
  void resonate() => throw PopsicleMelted("resonate()");

  @override
  void emitWithSignal(PopsicleSignal signal, {T? newState}) =>
      throw PopsicleMelted("emitWithSignal($signal, $newState)");

  @override
  void sendSignal(PopsicleSignal signal) => _base.sendSignal(signal);

  @override
  T get state => _base.state;

  @override
  PopsicleSignal get currentSignal => _base.currentSignal;

  @override
  StreamController<T> get _entanglementField => _base._entanglementField;

  @override
  bool get _observerEntangled => _base._observerEntangled;

  @override
  Listenable? get _source => _base._source;

  @override
  Function(_BasePopsicleState<T>)? get _observer => _base._observer;

  @override
  void _observe() => _base._observe();

  @override
  bool entangle(Listenable source, Function(_BasePopsicleState<T>) observer) =>
      _base.entangle(source, observer);

  @override
  bool disentangle({Function()? decay}) => _base.disentangle(decay: decay);

  @override
  void collapse() => _base.collapse();
}
