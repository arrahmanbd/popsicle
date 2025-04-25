import 'package:flutter/material.dart';
import 'package:popsicle/popsicle.dart';
import 'todo_state.dart';

class TodoScreen extends StatelessWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fetching Todos')),
      body: Center(child: TodoList()),
    );
  }
}

class TodoList extends StatelessWidget {
  const TodoList({super.key});

  @override
  Widget build(BuildContext context) {
    final state = resolve<TodoState>();
    // Listen to the state and rebuild the widget when it changes
    // This is a simple example, in a real app you would probably want to
    return state.todos.listen(
      onSuccess:
          (todos) => ListView.builder(
            itemCount: todos.length,
            itemBuilder: (_, index) {
              final todo = todos[index];
              return ListTile(
                title: Text(todo.title),
                trailing: Icon(
                  todo.completed ? Icons.check_circle : Icons.circle_outlined,
                  color: todo.completed ? Colors.green : Colors.grey,
                ),
              );
            },
          ),

      onError: (err) => Text("Error: $err"),
      onLoading: () => const CircularProgressIndicator(),
    );
  }
}
