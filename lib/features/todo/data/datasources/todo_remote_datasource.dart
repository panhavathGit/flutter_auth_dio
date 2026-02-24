import 'package:auth_dio/features/todo/data/datasources/todo_datasource.dart';
import 'package:dio/dio.dart';
import '../models/todo_model.dart';
import '../../../../core/network/dio_client.dart';

class TodoRemoteDatasource implements TodoDatasource{
  final DioClient _dioClient;

  TodoRemoteDatasource(this._dioClient);
  @override
  Future<List<TodoModel>> getTodos() async {
    final response = await _dioClient.dio.get('todos');
    final List data = response.data;
    return data.map((json) => TodoModel.fromJson(json)).toList();
  }
  @override
  Future<TodoModel> createTodo(TodoModel todo) async {
    final response = await _dioClient.dio.post(
      'todos',
      data: todo.toJson(),
    );
    return TodoModel.fromJson(response.data);
  }
  @override
  Future<TodoModel> updateTodo(TodoModel todo) async {
    final response = await _dioClient.dio.put(
      'todos/${todo.id}',
      data: todo.toJson(),
    );
    return TodoModel.fromJson(response.data);
  }
  @override
  Future<void> deleteTodo(int id) async {
    await _dioClient.dio.delete('todos/$id');
  }
}