part of '../../popsicle.dart';

/// Abstract interface for dependency injection configuration.
abstract interface class AppDI {
  /// Configures the dependency injection container with required dependencies.
  void initialize(DI di);
}

/// Function type for creating [AppDI] instances.
typedef ConfigBuilder = AppDI Function();
