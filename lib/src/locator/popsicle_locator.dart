part of 'package:popsicle/popsicle.dart';

class PopsicleLocator {
  // Singleton instance
  PopsicleLocator._private();
  static final instance = PopsicleLocator._private();

  // ==============================
  // Instance fields
  // ==============================
  final _singletons = <Type, Object>{};
  final _lazyFactories = <Type, FactoryFunc>{};
  final _asyncLazyFactories = <Type, FactoryFuncAsync>{};
  final _readyCompleters = <Type, Completer>{};

  // PopsicleState registry
  final _registry = <Type, PopsicleState<dynamic>>{};
  final _readonlyRegistry = <Type, ReadonlyState<dynamic>>{};
  final _factories = <Type, PopsicleState<dynamic> Function()>{};

  final List<PopsicleMiddleware<dynamic>> _globalMiddleware = [];

  // ==============================
  // Service-like getters
  // ==============================
  T get<T extends Object>() {
    if (_singletons.containsKey(T)) return _singletons[T] as T;

    if (_lazyFactories.containsKey(T)) {
      final factory = _lazyFactories.remove(T)!;
      final instance = factory();
      _singletons[T] = instance;
      return instance;
    }

    throw Exception("Type $T not registered.");
  }

  Future<T> getAsync<T extends Object>() async {
    if (_singletons.containsKey(T)) return _singletons[T] as T;

    if (_asyncLazyFactories.containsKey(T)) {
      final factory = _asyncLazyFactories.remove(T)!;
      final instance = await factory();
      _singletons[T] = instance;
      _readyCompleters[T]!.complete(instance);
      return instance;
    }

    throw Exception("Type $T not registered as async.");
  }

  void registerSingleton<T extends Object>(T instance) {
    _singletons[T] = instance;
  }

  void registerLazySingleton<T extends Object>(FactoryFunc<T> factory) {
    _lazyFactories[T] = factory;
  }

  void registerLazySingletonAsync<T extends Object>(
    FactoryFuncAsync<T> factory,
  ) {
    _asyncLazyFactories[T] = factory;
    _readyCompleters[T] = Completer<T>();
  }

  Future<void> isReady<T extends Object>() async {
    if (_singletons.containsKey(T)) return;
    if (_readyCompleters.containsKey(T)) await _readyCompleters[T]!.future;
  }

  void reset() {
    _singletons.clear();
    _lazyFactories.clear();
    _asyncLazyFactories.clear();
    _readyCompleters.clear();
    _registry.clear();
    _readonlyRegistry.clear();
    _factories.clear();
    _globalMiddleware.clear();
  }

  // ==============================
  // PopsicleState API
  // ==============================
  PopsicleState<T> getState<T>() {
    if (!_registry.containsKey(T)) {
      final factory = _factories[T];
      if (factory == null) {
        throw Exception('PopsicleState<$T> not registered or factory missing.');
      }
      _registerInstance(factory());
    }
    return _registry[T]! as PopsicleState<T>;
  }

  ReadonlyState<T> watch<T>() {
    if (!_readonlyRegistry.containsKey(T)) {
      getState<T>();
    }
    return _readonlyRegistry[T]! as ReadonlyState<T>;
  }

  void registerState<T>(PopsicleState<T> state) {
    _registerInstance(state);
  }

  void registerFactory<T>(PopsicleState<T> Function() factory) {
    if (_factories.containsKey(T)) {
      throw Exception('Factory for PopsicleState<$T> already registered.');
    }
    _factories[T] = factory;
  }

  void use<T>(PopsicleMiddleware<T> middleware) {
    final state = getState<T>();
    state.use(middleware);
  }

  // void useGlobal<T>(PopsicleMiddleware<dynamic> middleware) {
  //   _globalMiddleware.add(middleware);
  //   for (final state in _registry.values) {
  //     state.use(middleware);
  //   }
  // }
  void useGlobal<T>(PopsicleMiddleware<T> middleware) {
    // Cast middleware to dynamic so it works with all states
    _globalMiddleware.add(middleware as PopsicleMiddleware<dynamic>);

    for (final state in _registry.values) {
      state.use(middleware as PopsicleMiddleware<dynamic>);
    }
  }

  void collapse<T>() {
    final state = _registry.remove(T);
    _readonlyRegistry.remove(T);
    state?.collapse();
    _factories.remove(T);
  }

  void collapseAll() {
    for (final state in _registry.values) {
      state.collapse();
    }
    _registry.clear();
    _readonlyRegistry.clear();
    _factories.clear();
  }

  // ==============================
  // Internal helper
  // ==============================
  void _registerInstance(PopsicleState<dynamic> state) {
    final type = state.runtimeType;
    if (_registry.containsKey(type)) {
      throw Exception('PopsicleState<$type> is already registered.');
    }

    for (final mw in _globalMiddleware) {
      state.use(mw);
    }

    _registry[type] = state;
    _readonlyRegistry[type] = ReadonlyState(state);
  }

  // Aliases
  PopsicleState<T> lick<T>() => getState<T>();
  ReadonlyState<T> freeze<T>() => watch<T>();
  void melt<T>() => collapse<T>();
}
