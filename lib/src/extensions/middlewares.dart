part of 'package:popsicle/popsicle.dart';

// ignore: library_private_types_in_public_api
extension PopsicleStateMiddlewareExtension<T> on _BasePopsicleState<T> {
  /// Add middleware easily
  void addMiddleware(PopsicleMiddlewareBase<T> middleware) {
    use((oldState, newState) => middleware(oldState, newState));
  }
}

/// Popsicle middleware base class
abstract class PopsicleMiddlewareBase<T> {
  /// Transform or block updates
  T? call(T oldState, T newState);
}

/// Example: logging middleware
// class LoggingMiddleware<T> extends PopsicleMiddlewareBase<T> {
//   @override
//   T? call(T oldState, T newState) {
//     if (kDebugMode) {
//       print('Middleware: $oldState -> $newState');
//     }
//     return newState; // pass along
//   }
// }

extension Popsicles on Type {
  static T of<T extends Object>() => Popsicle.use<T>();
}
