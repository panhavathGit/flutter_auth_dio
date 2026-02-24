import '../models/todo_model.dart';

abstract class TodoRepository {
  Future<List<TodoModel>> getTodos();
  Future<TodoModel> createTodo(TodoModel todo);
  Future<TodoModel> updateTodo(TodoModel todo);
  Future<void> deleteTodo(int id);
}