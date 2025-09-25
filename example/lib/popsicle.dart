import 'package:example/logic/counter_logic.dart';
import 'package:example/logic/totdo_fetch.dart';
import 'package:popsicle/popsicle.dart';

/// 🌟 Function to register Popsicle services
void poplogic(PopsicleLogicLocator reg) {
  reg.registerLazySingleton<CounterLogic>(() => CounterLogic());
  reg.registerLazySingleton<CounterStreamLogic>(() => CounterStreamLogic());
  reg.registerLazySingleton<DrivingLogic>(() => DrivingLogic());
  reg.registerLazySingleton<TodoState>(() => TodoState());
  reg.useGlobal<int>((current, next) {
    print('CounterLogic changed: $current -> $next');
    return next;
  });
}

class DrivingLogic extends Logic<String> {
  DrivingLogic() : super('');

  void check(int age) {
    if (age >= 18) {
      shift('Yes you can Drive');
    } else {
      shift('You are not eligible');
    }
  }
}
