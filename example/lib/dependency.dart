import 'package:example/api_example/todo_state.dart';
import 'package:popsicle/popsicle.dart';
import 'api_example/todo_service.dart';

//Concrete configurator
class Dependency extends AppDI {
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
  }
}
