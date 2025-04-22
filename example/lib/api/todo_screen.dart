import 'package:example/api/todo_model.dart';
import 'package:flutter/material.dart';
import 'package:popsicle/popsicle.dart';

import 'todo_state.dart';

class TodoScreen extends StatelessWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TodoList();
  }
}

class TodoList extends StatelessWidget {
  const TodoList({super.key});

  @override
  Widget build(BuildContext context) {
    final state = inject<TodoState>();
    return StreamBuilder<List<Todo>>(
      stream: state.todos.stream,
      initialData: state.todos.value,
      builder: (_, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Column(
            children: [
              Center(child: CircularProgressIndicator()),
              IconButton(
                icon: const Icon(Icons.refresh_outlined),
                onPressed: () {
                  state.loadTodos();
                },
              ),
            ],
          );
        }

        final todos = snapshot.data!;
        return ListView.builder(
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
        );
      },
    );
  }
}
