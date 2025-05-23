import 'package:example/api_example/todo_state.dart';
import 'package:example/popsicle/new_state.dart';
import 'package:popsicle/popsicle.dart';
import 'api_example/todo_service.dart';

//Concrete configurator
class Dependency with TodoDependency implements AppDI {
  @override
  void initialize(DI di) {
    // dependency injection for MyState
    di.registerFactory<MyState>(() => MyState());

    todoConfig(di);
  }
}

// Using mixins for more modular approach
mixin TodoDependency {
  void todoConfig(DI di) {
    //  service class
    di.registerSingleton<TodoService>(TodoService());
    // dependency injection for TodoState
    // TodoState is a class that depends on TodoService
    // and is used to manage the state of the todo list
    di.registerFactory<TodoState>(() => TodoState(di.resolve<TodoService>()));
  }
}
