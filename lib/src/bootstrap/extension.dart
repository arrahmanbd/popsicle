part of '../../popsicle.dart';

/// Extension to provide convenient dependency injection syntax.
extension PopsicleInject<T> on T {
  /// Injects a dependency of type [T].
  T inject({String? id}) => Popsicle.provider<T>(id: id);
}

/// Resolves an instance of type [T] synchronously.
// T instanceOf<T>({String? id}) => Popsicle.provider<T>(id: id);

/// Resolves an instance of type [T] asynchronously.
// Future<T> instanceAsync<T>({String? id}) => Popsicle.instanceAsync<T>(id: id);
