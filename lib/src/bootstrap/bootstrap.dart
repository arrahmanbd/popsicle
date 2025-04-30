part of '../../popsicle.dart';

/// Bootstrapper class for the dependency injection system.
///
/// Provides methods to initialize, configure, and manage dependencies.
/// Supports singleton, factory, and lazy singleton registrations.
/// Includes error handling and dependency resolution capabilities.
class Popsicle {
  static final DIRegistry _registry = DIRegistry._internal();

  /// Private constructor to prevent instantiation.
  Popsicle._();

  /// Initializes and configures the dependency injection system.
  ///
  /// Throws [StateError] if already configured.
  static void bootstrap(AppDI dependency) {
    _registry.configure(dependency);
  }

  /// Provides access to the underlying registry.
  static DIRegistry get registry => _registry;

  /// Resolves a singleton instance of type [T].
  ///
  /// Throws [DependencyNotFoundException] if not registered.
  static T provider<T>({String? id}) => _registry.get<T>(id: id);

  /// Resolves a singleton instance of type [T] asynchronously.
  ///
  /// Throws [DependencyNotFoundException] if not registered.
  static Future<T> instanceAsync<T>({String? id}) =>
      _registry.getAsync<T>(id: id);

  /// Registers a singleton instance of type [T].
  static void registerSingleton<T>(T instance, {String? id}) =>
      _registry.registerSingleton<T>(instance, id: id);

  /// Registers a factory function for type [T].
  static void registerFactory<T>(T Function() factory, {String? id}) =>
      _registry.registerFactory<T>(factory, id: id);

  /// Registers a lazy singleton for type [T].
  static void registerLazySingleton<T>(T Function() factory, {String? id}) =>
      _registry.registerLazySingleton<T>(factory, id: id);

  /// Resets the dependency injection system.
  static void reset() => _registry.reset();

  /// Checks if a dependency of type [T] is registered.
  static bool isRegistered<T>({String? id}) =>
      _registry.isRegistered<T>(id: id);
}
