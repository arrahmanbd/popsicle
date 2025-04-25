part of '../../popsicle.dart';

/// Middleware context for advanced handling
// popsicle_middleware.dart
/// Holds context for a state change, used within middleware.
class MiddlewareContext<T> {
  final T oldValue;
  final T newValue;
  final String? key;
  final String? scope;

  MiddlewareContext({
    required this.oldValue,
    required this.newValue,
    this.key,
    this.scope,
  });
}

/// A single middleware function that takes a MiddlewareContext and returns a new state.
typedef Middleware<T> = T Function(MiddlewareContext<T> context);

/// A pipeline of middleware functions applied in sequence.
class MiddlewarePipeline<T> {
  final List<Middleware<T>> _middlewares = [];

  /// Add a new middleware to the pipeline.
  void add(Middleware<T> middleware) {
    _middlewares.add(middleware);
  }

  /// Apply all middlewares in sequence, returning the final result.
  T apply(MiddlewareContext<T> context) {
    var result = context.newValue;
    for (final middleware in _middlewares) {
      result = middleware(
        MiddlewareContext(
          oldValue: context.oldValue,
          newValue: result,
          key: context.key,
          scope: context.scope,
        ),
      );
    }
    return result;
  }

  /// Check if the pipeline has any middlewares.
  bool get hasMiddleware => _middlewares.isNotEmpty;

  /// Clear all middlewares.
  void clear() => _middlewares.clear();

  /// Create a new pipeline based on this one with an extra middleware.
  MiddlewarePipeline<T> copyWith(Middleware<T> middleware) {
    final copy = MiddlewarePipeline<T>();
    copy._middlewares.addAll(_middlewares);
    copy.add(middleware);
    return copy;
  }
}
