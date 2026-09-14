import 'package:flutter_riverpod/flutter_riverpod.dart';

class Todo {
  Todo(this.title, {this.done = false});
  final String title;
  final bool done;

  Todo copyWith({String? title, bool? done}) =>
      Todo(title ?? this.title, done: done ?? this.done);
}

class TodoListNotifier extends Notifier<List<Todo>> {
  @override
  List<Todo> build() => const [];

  void add(String title) => state = [...state, Todo(title)];

  void toggle(Todo target) {
    state = [
      for (final todo in state)
        if (identical(todo, target)) todo.copyWith(done: !todo.done) else todo,
    ];
  }

  void remove(Todo target) {
    state = [for (final todo in state) if (!identical(todo, target)) todo];
  }
}

final todoListProvider =
    NotifierProvider<TodoListNotifier, List<Todo>>(TodoListNotifier.new);

final unfinishedTodosProvider = Provider<List<Todo>>((ref) {
  final todos = ref.watch(todoListProvider);
  return List.unmodifiable(todos.where((todo) => !todo.done));
});
