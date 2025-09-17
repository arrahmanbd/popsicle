part of 'package:popsicle/popsicle.dart';



/// 🧊 PopsicleLocator — Service Locator for PopsicleState<T> and ReadonlyState< T>
/// 

class PopsicleLocator {
  PopsicleLocator._();

  static final Map<Type, PopsicleState<dynamic>> _registry = {};
  static final Map<Type, ReadonlyState<dynamic>> _readonlyRegistry = {};

  // ==============================
  // Bootstrap
  // ==============================

  /// 🚀 Bootstrap multiple logic instances at once
  ///
  /// Example:
  /// ```dart
  /// PopsicleLocator.bootstrap([
  ///   () => CounterLogic(),
  ///   () => DrivingLogic(),
  /// ]);
  /// ```
  static void bootstrap(List<PopsicleState<dynamic>> Function() createList) {
    final instances = createList();
    for (final logic in instances) {
      _registerInstance(logic);
    }
  }

  // ==============================
  // Registration
  // ==============================

  static void register<T>(PopsicleState<T> state) {
    _registerInstance(state);
  }

  static void _registerInstance(PopsicleState<dynamic> state) {
    final type = state.runtimeType;
    if (_registry.containsKey(type)) {
      throw Exception('PopsicleState<$type> is already registered.');
    }
    _registry[type] = state;
    _readonlyRegistry[type] = ReadonlyState(state);
  }

  static void unregister<T>() {
    _registry.remove(T);
    _readonlyRegistry.remove(T);
  }

  // ==============================
  // Access
  // ==============================

  static PopsicleState<T> get<T>() {
    final state = _registry[T];
    if (state == null) throw Exception('PopsicleState<$T> is not registered.');
    return state as PopsicleState<T>;
  }

  static ReadonlyState<T> watch<T>() {
    final state = _readonlyRegistry[T];
    if (state == null) throw Exception('ReadonlyState<$T> is not registered.');
    return state as ReadonlyState<T>;
  }

  static bool isRegistered<T>() => _registry.containsKey(T);

  // ==============================
  // Middleware
  // ==============================

  static void use<T>(QuantumMiddleware<T> middleware) {
    final state = get<T>();
    state.use(middleware);
  }

  // ==============================
  // Lifecycle
  // ==============================

  static void collapse<T>() {
    final logic = _registry.remove(T);
    _readonlyRegistry.remove(T);
    logic?.collapse();
  }

  static void collapseAll() {
    for (final logic in _registry.values) {
      logic.collapse();
    }
    _registry.clear();
    _readonlyRegistry.clear();
  }
}

