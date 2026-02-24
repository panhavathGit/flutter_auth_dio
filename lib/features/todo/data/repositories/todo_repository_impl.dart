import 'package:dio/dio.dart';
import '../datasources/todo_datasource.dart';
import '../models/todo_model.dart';
import 'todo_repository.dart';

class TodoRepositoryImpl implements TodoRepository {
  final TodoDatasource _datasource; // ← abstract, accepts both mock and real

  TodoRepositoryImpl(this._datasource);

  @override
  Future<List<TodoModel>> getTodos() async {
    try {
      return await _datasource.getTodos();
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<TodoModel> createTodo(TodoModel todo) async {
    try {
      return await _datasource.createTodo(todo);
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<TodoModel> updateTodo(TodoModel todo) async {
    try {
      return await _datasource.updateTodo(todo);
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<void> deleteTodo(int id) async {
    try {
      await _datasource.deleteTodo(id);
    } catch (e) {
      throw e.toString();
    }
  }
}