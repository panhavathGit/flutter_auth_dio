import 'todo_datasource.dart';
import '../models/todo_model.dart';

class TodoMockDatasource implements TodoDatasource {
  // In-memory list — acts like a local database
  final List<TodoModel> _todos = [
    TodoModel(
      id: 1,
      title: 'Buy groceries',
      description: 'Milk, eggs, bread, and coffee',
      dueDate: DateTime.now().add(const Duration(days: 1)),
      isCompleted: false,
    ),
    TodoModel(
      id: 2,
      title: 'Read Flutter docs',
      description: 'Study state management with Provider',
      dueDate: DateTime.now().add(const Duration(days: 3)),
      isCompleted: true,
    ),
    TodoModel(
      id: 3,
      title: 'Fix login bug',
      description: 'Token is not persisting after app restart',
      dueDate: DateTime.now().subtract(const Duration(days: 1)), // overdue!
      isCompleted: false,
    ),
  ];

  int _nextId = 4; // auto increment id

  Future<void> _delay() => Future.delayed(const Duration(milliseconds: 800));

  @override
  Future<List<TodoModel>> getTodos() async {
    await _delay();
    return List.from(_todos); // return a copy
  }

  @override
  Future<TodoModel> createTodo(TodoModel todo) async {
    await _delay();
    final newTodo = TodoModel(
      id: _nextId++,
      title: todo.title,
      description: todo.description,
      dueDate: todo.dueDate,
      isCompleted: false,
    );
    _todos.add(newTodo);
    return newTodo;
  }

  @override
  Future<TodoModel> updateTodo(TodoModel todo) async {
    await _delay();
    final index = _todos.indexWhere((t) => t.id == todo.id);
    if (index == -1) throw Exception('Todo not found');
    _todos[index] = todo;
    return todo;
  }

  @override
  Future<void> deleteTodo(int id) async {
    await _delay();
    final index = _todos.indexWhere((t) => t.id == id);
    if (index == -1) throw Exception('Todo not found');
    _todos.removeAt(index);
  }
}