import 'dart:convert';
import 'package:example/api/todo_model.dart';
import 'package:http/http.dart' as http;

class TodoService {
  Future<List<Todo>> fetchTodos() async {
    final url = Uri.parse("https://jsonplaceholder.typicode.com/todos");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Todo.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load todos");
    }
  }
}
