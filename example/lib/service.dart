import 'package:example/logic/counter_logic.dart';
import 'package:example/logic/totdo_fetch.dart';
import 'package:popsicle/popsicle.dart';

/// 🌟 Function to register Popsicle services
void registerServices(PopsicleLocator reg) {
  // Register services
  reg.registerLazySingleton<CounterLogic>(() => CounterLogic());
  reg.registerLazySingleton<TodoState>(() => TodoState());

  // Optional: global observer
  reg.useGlobal<int>((current, next) {
    print('CounterLogic changed: $current -> $next');
    return next;
  });
}
