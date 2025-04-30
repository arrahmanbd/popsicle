part of '../../popsicle.dart';

/// Dependency injection registry using singleton pattern for global access.
///
/// Manages the lifecycle of dependencies and provides methods for registration
/// and resolution of dependencies, both synchronously and asynchronously.
class DIRegistry {
  static final DIRegistry _instance = DIRegistry._internal();

  /// Factory constructor to access the singleton instance.
  factory DIRegistry() => _instance;

  final DI _container = DI();
  bool _isConfigured = false;

  DIRegistry._internal();

  /// Configures the registry with the provided [configurator].
  ///
  /// Throws [StateError] if already configured.
  void configure(AppDI configurator) {
    if (_isConfigured) {
      throw StateError('DIRegistry is already configured.');
    }
    configurator.initialize(_container);
    _isConfigured = true;
  }

  /// Resolves a dependency of type [T] synchronously.
  ///
  /// Throws [DependencyNotFoundException] if the dependency is not registered.
  T get<T>({String? id}) => _container.resolve<T>(id: id);

  /// Resolves a dependency of type [T] asynchronously.
  ///
  /// Throws [DependencyNotFoundException] if the dependency is not registered.
  Future<T> getAsync<T>({String? id}) => _container.resolveAsync<T>(id: id);

  /// Registers a singleton instance of type [T].
  void registerSingleton<T>(T instance, {String? id}) =>
      _container.registerSingleton<T>(instance, id: id);

  /// Registers a factory function for type [T].
  void registerFactory<T>(T Function() factory, {String? id}) =>
      _container.registerFactory<T>(factory, id: id);

  /// Registers a lazy singleton that is created only when first accessed.
  void registerLazySingleton<T>(T Function() factory, {String? id}) =>
      _container.registerLazySingleton<T>(factory, id: id);

  /// Clears all registered dependencies and resets configuration state.
  void reset() {
    _container.clear();
    _isConfigured = false;
  }

  /// Checks if a dependency of type [T] is registered.
  bool isRegistered<T>({String? id}) => _container.isRegistered<T>(id: id);
}
