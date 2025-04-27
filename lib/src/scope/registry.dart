part of '../../popsicle.dart';
/// Abstract class for configuration logic.
abstract class AppDI {
  void configure(DIContainer container);
}

/// A function that returns a [AppDI] instance.
typedef ConfigBuilder = AppDI Function();

/// Singleton-based DI registry for global access and bootstrapping.

class DIRegistry {
  static final DIRegistry _instance = DIRegistry._internal();
  factory DIRegistry() => _instance;

  final DIContainer _container = DIContainer();
  bool _isConfigured = false;

  DIRegistry._internal();

  void configure(AppDI configurator) {
    if (_isConfigured) return;
    configurator.configure(_container);
    _isConfigured = true;
  }

  T get<T>({String? id}) => _container.resolve<T>(id: id);
  Future<T> getAsync<T>({String? id}) => _container.resolveAsync<T>(id: id);

  void registerSingleton<T>(T instance, {String? id}) => _container.registerSingleton<T>(instance, id: id);

  void reset() {
    _container.clear();
    _isConfigured = false;
  }
}
