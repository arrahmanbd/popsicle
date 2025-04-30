part of '../../popsicle.dart';

/// Exception thrown when a dependency is not found in the container.
class DependencyNotFoundException implements Exception {
  final String message;

  DependencyNotFoundException(this.message);

  @override
  String toString() => 'DependencyNotFoundException: $message';
}

class DependencyCycleException implements Exception {
  final String message;
  DependencyCycleException(this.message);
  @override
  String toString() => 'DependencyCycleException: $message';
}
