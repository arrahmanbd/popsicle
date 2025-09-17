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
class PopsicleState<T> implements Listenable {
  /// 🍦 Current flavor of the popsicle
  T state;

  /// 🍭 Current signal/state of the popsicle
  PopsicleSignal currentSignal = PopsicleSignal.idle;

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
  Function(PopsicleState<T>)? _observer;
  bool _observerEntangled = false;
  bool _canCollapse = true;
  Listenable? _source;

  PopsicleState({
    required this.state,
    this.currentSignal = PopsicleSignal.idle,
  });

  // ==============================
  // Middleware
  // ==============================

  /// 🛠 Add middleware to transform or block popsicle updates
  void use(PopsicleMiddleware<T> middleware) => _middleware.add(middleware);

  // ==============================
  // State Emission
  // ==============================

  /// 🍦 Bite into the popsicle (update state), passing through middleware
  void shift(T newState, {PopsicleSignal signal = PopsicleSignal.emit}) {
    if (!_canCollapse) return;

    T processedState = newState;

    // Apply middleware chain
    for (final mw in _middleware) {
      final result = mw(state, processedState);
      if (result == null) return; // cancel update
      processedState = result;
    }

    state = processedState;
    currentSignal = signal;

    if (!_entanglementField.isClosed) _entanglementField.add(processedState);
    _notifyListeners();
  }

  /// 🍓 Update only if the flavor changed
  void emitIfChanged(T newState) {
    if (state != newState) shift(newState);
  }

  /// 🍪 Re-share the current flavor without changing it
  void resonate() {
    if (!_entanglementField.isClosed) _entanglementField.add(state);
    currentSignal = PopsicleSignal.update;
  }

  /// 🧊 Emit a signal, optionally with a new flavor
  void emitWithSignal(PopsicleSignal signal, {T? newState}) {
    if (newState != null && newState != state) {
      shift(newState, signal: signal);
    } else {
      if (!_entanglementField.isClosed) _entanglementField.add(state);
      currentSignal = signal;
    }
  }

  /// 📡 Send a signal without changing the flavor
  void sendSignal(PopsicleSignal signal) {
    currentSignal = signal;
    if (!_entanglementField.isClosed) _entanglementField.add(state);
  }

  // ==============================
  // Observation / Entanglement
  // ==============================

  /// 🔗 Entangle with an external Listenable
  bool entangle(Listenable source, Function(PopsicleState<T>) observer) {
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

  /// ❄️ Remove entanglement
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

  /// 🌊 Drip in values from a stream automatically
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
  // Lifecycle
  // ==============================

  /// 🔥 Melt the popsicle and clean up
  void collapse() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();

    _entanglementField.close();
    _canCollapse = false;
    _source?.removeListener(_observe);
    _resetQuantumState();
    currentSignal = PopsicleSignal.done;
  }

  /// ❄️ Reset the popsicle state optionally with a signal
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
  }

  // ==============================
  // Listenable Implementation
  // ==============================

  @override
  void addListener(VoidCallback listener) => _listeners.add(listener);

  @override
  void removeListener(VoidCallback listener) => _listeners.remove(listener);

  void _notifyListeners() {
    for (final l in _listeners) {
      l();
    }
  }

  // ==============================
  // Getters
  // ==============================

  /// 🌊 Stream of popsicle flavors
  Stream<T> get field => _entanglementField.stream;

  /// ❄️ Can this popsicle still be updated?
  bool get canEmit => _canCollapse;
}

/// ❄️ **ReadonlyState** — A frozen popsicle.
///
/// Wraps a [PopsicleState] in a read-only shell.
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
class ReadonlyState<T> extends PopsicleState<T> {
  final PopsicleState<T> _base;

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
  Function(PopsicleState<T>)? get _observer => _base._observer;

  @override
  void _observe() => _base._observe();

  @override
  bool entangle(Listenable source, Function(PopsicleState<T>) observer) =>
      _base.entangle(source, observer);

  @override
  bool disentangle({Function()? decay}) => _base.disentangle(decay: decay);

  @override
  void collapse() => _base.collapse();
}
