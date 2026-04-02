import 'package:flutter/material.dart';
import 'package:signals/signals.dart';

/// A small todo list application that illustrates a more "architectural"
/// usage of the signal system.  Layers are separated cleanly:
///
///  * **Model** - simple data object wrapping its own reactive fields.
///  * **Repository** - holds the source-of-truth signal list and provides
///    methods for mutation.
///  * **ViewModel** - exposes data and operations to the UI, along with
///    computed values derived from the repository.
///  * **UI** - Flutter widgets built on top of `UI`/`effect` that consume the
///    view model.
///
/// The intent is to show how you might structure a real application while
/// still taking advantage of the tiny reactive engine.

// ---------- model --------------------------------------------------------

class Todo {
  Todo(this.description, {bool completed = false})
    : _completed = signal(completed);

  final String description;
  final Signal<bool> _completed;

  bool call() => _completed();
  bool get isCompleted => _completed();
  set isCompleted(bool v) => _completed(v);
  Signal<bool> get completedSignal => _completed;
}

// ---------- repository ---------------------------------------------------

class TodoRepository {
  final Signal<List<Todo>> _todos = signal<List<Todo>>([]);

  /// Returns a reactive list of todos.
  Signal<List<Todo>> get todosSignal => _todos;

  /// Read-only snapshot convenience.
  List<Todo> get todos => _todos();

  void addTodo(String description) {
    _todos([..._todos(), Todo(description)]);
  }

  void removeTodo(Todo t) {
    _todos(_todos().where((e) => e != t).toList());
  }
}

// ---------- view model ---------------------------------------------------

class TodoViewModel {
  final TodoRepository _repo;

  /// Number of unfinished items.
  late final Computed<int> remaining;

  TodoViewModel(this._repo) {
    remaining = computed(() {
      return _repo.todos.where((t) => !t.isCompleted).length;
    });
  }

  Signal<List<Todo>> get todoList => _repo.todosSignal;
  int get remainingCount => remaining();

  void add(String description) => _repo.addTodo(description);
  void remove(Todo t) => _repo.removeTodo(t);
}

// ---------- application --------------------------------------------------

void main() {
  final repo = TodoRepository();
  final vm = TodoViewModel(repo);
  runApp(TodoApp(vm));
}

class TodoApp extends UI {
  final TodoViewModel vm;
  TodoApp(this.vm);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Signals Architecture Demo',
      home: TodoPage(vm: vm),
    );
  }
}

class TodoPage extends UI {
  final TodoViewModel vm;
  TodoPage({required this.vm});

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final todos = vm.todoList();

    return Scaffold(
      appBar: AppBar(title: Text('Todos (${vm.remainingCount})')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(controller: _controller),
                ),
                ElevatedButton(
                  onPressed: () {
                    final text = _controller.text.trim();
                    if (text.isNotEmpty) {
                      vm.add(text);
                      _controller.clear();
                    }
                  },
                  child: Text('Add'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: todos.map((t) {
                return CheckboxListTile(
                  title: Text(t.description),
                  value: t.isCompleted,
                  onChanged: (v) => t.isCompleted = v ?? false,
                  secondary: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => vm.remove(t),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
