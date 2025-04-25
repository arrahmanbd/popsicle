import 'package:example/api_example/todo_service.dart';
import 'package:popsicle/popsicle.dart';
import 'todo_model.dart';

class TodoState {
  final TodoService todoService;
  TodoState(this.todoService) {
    loadTodos();
  }

  final StreamState<List<Todo>> todos =
      ReactiveProvider.createStream<List<Todo>>('todos', []);

  Future<void> loadTodos() async {
    try {
      final fetchedTodos = await todoService.fetchTodos();
      todos.update(fetchedTodos);
    } catch (e) {
      //print("Error loading todos: $e");
    }
  }

  void clearAll() {
    todos.value.clear();
  }
}
