part of '../../popsicle.dart';

/// 🛠 Middleware function type
typedef Middleware<T> = T Function(T previous, T next);

/// Middleware system that allows chaining multiple middlewares
class MiddlewarePipeline<T> {
  final List<Middleware<T>> _middlewares = [];

  /// Add a middleware
  void add(Middleware<T> middleware) {
    _middlewares.add(middleware);
  }

  /// Apply middleware to a state update
  T apply(T previous, T next) {
    var modifiedState = next;
    for (var middleware in _middlewares) {
      modifiedState = middleware(previous, modifiedState);
    }
    return modifiedState;
  }
}
