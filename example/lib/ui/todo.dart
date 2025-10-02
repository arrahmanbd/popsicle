import 'package:example/logic/totdo_fetch.dart';
import 'package:flutter/material.dart';
import 'package:popsicle/popsicle.dart';

class TodoModule extends StatelessWidget {
  const TodoModule({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todos')),
      body: PopWidget<PopState<List<Todo>>, TodoState>(
        create: () => Popsicle.use<TodoState>(),
        builder: (context, state, logic) {
          if (state is PopLoading<List<Todo>>) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PopFailure<List<Todo>>) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.error}'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: logic.fetchTodos,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is PopSuccess<List<Todo>>) {
            final todos = state.data;
            if (todos.isEmpty) {
              return const Center(child: Text('No todos available.'));
            }
            return ListView.separated(
              itemCount: todos.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final todo = todos[index];
                return ListTile(
                  title: Text(todo.todo),
                  leading: Icon(
                    todo.completed
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    color: todo.completed ? Colors.green : null,
                  ),
                  subtitle: Text('User: ${todo.userId} | ID: ${todo.id}'),
                );
              },
            );
          } else {
            return const Center(
              child: Text('Press the button to fetch todos.'),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Popsicle.use<TodoState>().fetchTodos();
        },
        child: const Icon(Icons.download),
        tooltip: 'Fetch Todos',
      ),
    );
  }
}
