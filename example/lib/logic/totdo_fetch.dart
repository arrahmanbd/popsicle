// ==============================
// Todo Model
// ==============================
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:popsicle/popsicle.dart';

class Todo {
  final int id;
  final String todo;
  final bool completed;
  final int userId;

  Todo({
    required this.id,
    required this.todo,
    required this.completed,
    required this.userId,
  });

  // Factory constructor for JSON parsing
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] as int,
      todo: json['todo'] as String,
      completed: json['completed'] as bool,
      userId: json['userId'] as int,
    );
  }

  // Convert back to JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'todo': todo, 'completed': completed, 'userId': userId};
  }

  @override
  String toString() {
    return 'Todo(id: $id, todo: "$todo", completed: $completed, userId: $userId)';
  }
}

abstract class AppState<T> {
  const AppState();
}

class AppLoading<T> extends AppState<T> {
  const AppLoading();
}

class AppSuccess<T> extends AppState<T> {
  final T data;
  const AppSuccess(this.data);
}

class AppFailure<T> extends AppState<T> {
  final String error;
  const AppFailure(this.error);
}

class TodoState extends PopsicleState<AppState<List<Todo>>> {
  TodoState() : super(state: const AppLoading());

  void fetchTodos() {
    shift(const AppLoading());

    _getTodos()
        .then((todos) => shift(AppSuccess(todos)))
        .catchError((e) => shift(AppFailure(e.toString())));
  }

  Future<List<Todo>> _getTodos() async {
    final response = await http.get(Uri.parse('https://dummyjson.com/todos'));
    if (response.statusCode != 200) throw Exception('Failed to fetch todos');

    final decoded = json.decode(response.body) as Map<String, dynamic>;
    final todos = List<Map<String, dynamic>>.from(decoded['todos'] as List);
    return todos.map((e) => Todo.fromJson(e)).toList();
  }
}
