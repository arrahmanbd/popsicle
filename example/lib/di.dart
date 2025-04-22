import 'package:example/api/todo_state.dart';
import 'package:example/counter/counter_state.dart';
import 'package:example/main.dart';
import 'package:popsicle/popsicle.dart';
import 'api/todo_service.dart';

/// Concrete configurator
class AppDI extends DIConfigurator {
  @override
  void configure(DIContainer container) {
    //  service class
    container.registerSingleton<TodoService>(TodoService());
    // dependency injection for TodoState
    // TodoState is a class that depends on TodoService
    // and is used to manage the state of the todo list
    container.registerFactory<TodoState>(
      () => TodoState(container.resolve<TodoService>()),
    );
    // Counter State
    container.registerFactory(() => CounterState2());
    //  LoggerService
    container.registerSingleton<LoggerService>(LoggerService());
    //  MyController
    container.registerSingleton<MyController>(MyController());
  }
}
