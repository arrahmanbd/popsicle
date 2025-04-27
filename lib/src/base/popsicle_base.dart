part of '../../popsicle.dart';

abstract class Popsicle {
  /// Bootstrap DI without context or InheritedWidget.
  static void bootstrap(AppDI configurator) {
    DIRegistry().configure(configurator);
  }

  List<ReactiveState> get states;

  void onInit() {}

  void dispose() {
    for (final state in states) {
      state.dispose();
    }
  }
}
