// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'package:popsicle/popsicle.dart';

typedef PopsicleModule = void Function(PopsicleLogicLocator);

class Popsicle {
  static final init = PopsicleLogicLocator.instance;
  static void bootStrap(PopsicleServices di) {
    init;
    // call the provided service registration with our locator
    di(init);
  }

  /// Register multiple modules at once
  /// Example:
  /// ```dart
  /// void authLogic(PopsicleLogicLocator reg) {
  //   reg.registerLazySingleton<AuthLogic>(() => AuthLogic());
  // }

  // void profileLogic(PopsicleLogicLocator reg) {
  //   reg.registerLazySingleton<ProfileLogic>(() => ProfileLogic());
  // }
  /// Popsicle.bootModules([authLogic, profileLogic]);
  /// ```
  static void bootModules(List<PopsicleModule> modules) {
    init;
    // call each module with our locator
    for (final m in modules) {
      m(init);
    }
  }

  /// Helper to get registered lazy singleton
  static T get<T extends Object>() => init.get<T>();
}
