part of '../../popsicle.dart';

/// Base class for state management Base
abstract class ReactiveStateBase<T> {
  T get value;
  void update(T newValue);
  void dispose();
  void onInit() {}
  void onDispose() {}
}
