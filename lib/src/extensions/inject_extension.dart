part of '../../popsicle.dart';

//  Access global injection without context
/// Global injection method (no context required)
T inject<T>() => PopsicleDI.global.resolve<T>();

/// Extension on [DIContainer] to provide a global resolve method
extension DIGlobalX on PopsicleDI {
  /// Global resolve method (no context required)
  static T instance<T>() => PopsicleDI.global.resolve<T>();
}
