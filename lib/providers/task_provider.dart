import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../services/task_service.dart';

final tasksProvider = AsyncNotifierProvider<TasksNotifier, List<Task>>(() {
  return TasksNotifier();
});

class TasksNotifier extends AsyncNotifier<List<Task>> {
  final _service = TaskService();

  @override
  Future<List<Task>> build() async {
    return _service.getTasks();
  }

  Future<void> addTask(String title) async {
    final newTask = await _service.createTask(title);
    state = AsyncData([newTask, ...?state.value]);
  }

  Future<void> toggleTask(Task task) async {
    final updated = await _service.updateTask(task.id, !task.done);
    state = AsyncData([
      for (final t in state.value ?? [])
        if (t.id == task.id) updated else t,
    ]);
  }

  Future<void> deleteTask(Task task) async {
    await _service.deleteTask(task.id);
    state = AsyncData(
      state.value?.where((t) => t.id != task.id).toList() ?? [],
    );
  }
}
