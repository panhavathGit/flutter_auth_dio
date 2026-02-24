import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/todo_viewmodel.dart';
import '../../data/models/todo_model.dart';
import 'todo_form_screen.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:auth_dio/core/routes/app_routes.dart';
import 'package:go_router/go_router.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<TodoViewModel>().loadTodos());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Todos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TodoFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Consumer<TodoViewModel>(
        builder: (context, viewModel, _) {
          // loading state
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // error state
          if (viewModel.state == TodoState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(
                    viewModel.errorMessage ?? 'Something went wrong',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => viewModel.loadTodos(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // empty state
          if (viewModel.todos.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 80, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'No todos yet!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Tap + to create your first todo.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // todo list
          return RefreshIndicator(
            onRefresh: () => viewModel.loadTodos(),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: viewModel.todos.length,
              itemBuilder: (context, index) {
                final todo = viewModel.todos[index];
                return _TodoCard(todo: todo);
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    await context.read<AuthViewModel>().logout();
    if (mounted) {
      context.go(AppPaths.login);
    }
  }
}

// ─────────────────────────────────────────────
// Todo Card Widget
// ─────────────────────────────────────────────

class _TodoCard extends StatelessWidget {
  final TodoModel todo;

  const _TodoCard({required this.todo});

  @override
  Widget build(BuildContext context) {
    final isOverdue = !todo.isCompleted &&
        todo.dueDate.isBefore(DateTime.now());

    return Dismissible(
      key: Key(todo.id.toString()),
      direction: DismissDirection.endToStart,

      // red delete background when swiping
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete, color: Colors.white),
            SizedBox(height: 4),
            Text('Delete', style: TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),

      // confirm before deleting
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Delete Todo'),
            content: Text('Are you sure you want to delete "${todo.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },

      onDismissed: (_) {
        context.read<TodoViewModel>().deleteTodo(todo.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${todo.title}" deleted'),
            action: SnackBarAction(label: 'OK', onPressed: () {}),
          ),
        );
      },

      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

          // checkbox to toggle complete
          leading: Checkbox(
            value: todo.isCompleted,
            onChanged: (_) {
              context.read<TodoViewModel>().updateTodo(
                    todo.copyWith(isCompleted: !todo.isCompleted),
                  );
            },
          ),

          title: Text(
            todo.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              decoration: todo.isCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
              color: todo.isCompleted ? Colors.grey : Colors.black,
            ),
          ),

          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (todo.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  todo.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 12,
                    color: isOverdue ? Colors.red : Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${todo.dueDate.day}/${todo.dueDate.month}/${todo.dueDate.year}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isOverdue ? Colors.red : Colors.grey,
                      fontWeight: isOverdue
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  if (isOverdue) ...[
                    const SizedBox(width: 6),
                    const Text(
                      'Overdue',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),

          // edit button
          trailing: IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.blue),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TodoFormScreen(todo: todo),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}