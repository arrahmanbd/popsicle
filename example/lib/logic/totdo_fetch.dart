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

abstract class PopState<T> {
  const PopState();
}

class PopLoading<T> extends PopState<T> {
  const PopLoading();
}

class PopSuccess<T> extends PopState<T> {
  final T data;
  const PopSuccess(this.data);
}

class PopFailure<T> extends PopState<T> {
  final String error;
  const PopFailure(this.error);
}

class TodoState extends Logic<PopState<List<Todo>>> {
  TodoState() : super(PopLoading());

  void fetchTodos() {
    shift(const PopLoading());

    _getTodos()
        .then((todos) => shift(PopSuccess(todos)))
        .catchError((e) => shift(PopFailure(e.toString())));
  }

  Future<List<Todo>> _getTodos() async {
    final response = await http.get(Uri.parse('https://dummyjson.com/todos'));
    if (response.statusCode != 200) throw Exception('Failed to fetch todos');

    final decoded = json.decode(response.body) as Map<String, dynamic>;
    final todos = List<Map<String, dynamic>>.from(decoded['todos'] as List);
    return todos.map((e) => Todo.fromJson(e)).toList();
  }
}

TodoState useTodoState() => Popsicle.get<TodoState>();
