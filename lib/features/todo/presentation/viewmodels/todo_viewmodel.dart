import 'package:flutter/foundation.dart';
import '../../data/models/todo_model.dart';
import '../../data/repositories/todo_repository.dart';

enum TodoState { idle, loading, success, error }

class TodoViewModel extends ChangeNotifier {
  final TodoRepository _todoRepository;

  TodoViewModel(this._todoRepository);

  TodoState _state = TodoState.idle;
  List<TodoModel> _todos = [];
  String? _errorMessage;

  TodoState get state => _state;
  List<TodoModel> get todos => _todos;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == TodoState.loading;

  Future<void> loadTodos() async {
    _setState(TodoState.loading);
    try {
      _todos = await _todoRepository.getTodos();
      _setState(TodoState.success);
    } catch (e) {
      _errorMessage = e.toString();
      _setState(TodoState.error);
    }
  }

  Future<bool> createTodo(TodoModel todo) async {
    _setState(TodoState.loading);
    try {
      final newTodo = await _todoRepository.createTodo(todo);
      _todos.add(newTodo);
      _setState(TodoState.success);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setState(TodoState.error);
      return false;
    }
  }

  Future<bool> updateTodo(TodoModel todo) async {
    _setState(TodoState.loading);
    try {
      final updated = await _todoRepository.updateTodo(todo);
      final index = _todos.indexWhere((t) => t.id == updated.id);
      if (index != -1) _todos[index] = updated;
      _setState(TodoState.success);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setState(TodoState.error);
      return false;
    }
  }

  Future<bool> deleteTodo(int id) async {
    try {
      await _todoRepository.deleteTodo(id);
      _todos.removeWhere((t) => t.id == id);
      _setState(TodoState.success);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setState(TodoState.error);
      return false;
    }
  }

  void _setState(TodoState state) {
    _state = state;
    notifyListeners();
  }
}
