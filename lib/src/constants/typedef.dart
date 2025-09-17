part of 'package:popsicle/popsicle.dart';

typedef PopsicleBuilder<T> = Widget Function(BuildContext context, T state);

typedef PopsicleBuilderWithEntangle<T> =
    Widget Function(BuildContext context, T? state, PopsicleSignal signal);

typedef PopsicleBuilderWithLogic<T, L extends PopsicleState<T>> =
    Widget Function(BuildContext context, T value, L logic);

typedef PopsicleMiddleware<T> = T? Function(T current, T next);

/// Middleware for PopsicleState

/// Abstract Popsicle middleware with lifecycle hooks
abstract class Middleware<T> {
  /// Called before the state changes.
  /// You can inspect `oldValue` and `newValue` and optionally throw
  /// or modify behavior (if you later implement a return type).
  void beforeChange(T oldValue, T newValue) {}

  /// Called after the state has changed.
  void afterChange(T newValue) {}
}

typedef FactoryFunc<T> = T Function();
typedef FactoryFuncAsync<T> = Future<T> Function();

/// 🌟 Typedef for Popsicle service registration callback
typedef PopsicleServices = void Function(PopsicleLocator locator);
