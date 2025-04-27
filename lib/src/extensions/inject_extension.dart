part of '../../popsicle.dart';

//  Access global injection without context
/// Global injection method (no context required)

// Bootstrap DI without context or InheritedWidget.
void bootstrapDI(AppDI configurator) {
  DIRegistry().configure(configurator);
}

/// Global shorthand for DI resolution.
T resolve<T>() => DIRegistry().get<T>();
Future<T> injectAsync<T>() => DIRegistry().getAsync<T>();
