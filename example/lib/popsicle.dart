import 'package:example/logic/counter_logic.dart';
import 'package:example/logic/driving_logic.dart';
import 'package:example/logic/totdo_fetch.dart';
import 'package:popsicle/popsicle.dart';

/// 🌟 Function to register Popsicle services
void popsicle(PopsicleLocator reg) {
  reg.registerLazySingleton<CounterLogic>(() => CounterLogic());
  reg.registerLazySingleton<DrivingLogic>(() => DrivingLogic());
  reg.registerLazySingleton<TodoState>(() => TodoState());
  reg.useGlobal<int>((current, next) {
    print('CounterLogic changed: $current -> $next');
    return next;
  });
}
