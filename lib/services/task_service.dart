import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task.dart';

class TaskService {
  final SupabaseClient _client = Supabase.instance.client;

  // Local in-memory store so the app is 100% interactive even if SQL table isn't created yet
  static final List<Task> _localFallback = [
    Task(id: 1, title: 'Master Flutter Animations & Cyber UI', done: true),
    Task(id: 2, title: 'Complete today\'s 25m Focus Chamber block', done: false),
    Task(id: 3, title: 'Dominate the AI Quiz Arena with 5x combo', done: false),
    Task(id: 4, title: 'Generate high-yield cognitive summary', done: false),
  ];
  static bool _hasCloudTable = true;

  Future<List<Task>> getTasks() async {
    if (!_hasCloudTable) {
      return List.from(_localFallback);
    }
    try {
      final response = await _client
          .from('tasks')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => Task.fromJson(item as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST205') {
        _hasCloudTable = false;
        return List.from(_localFallback);
      }
      return List.from(_localFallback);
    } catch (_) {
      return List.from(_localFallback);
    }
  }

  Future<Task> createTask(String title) async {
    final cleanTitle = title.trim();
    if (!_hasCloudTable) {
      final localTask = Task(
        id: DateTime.now().millisecondsSinceEpoch % 1000000,
        title: cleanTitle,
        done: false,
      );
      _localFallback.insert(0, localTask);
      return localTask;
    }
    try {
      final response = await _client
          .from('tasks')
          .insert({
            'title': cleanTitle,
            'done': false,
          })
          .select()
          .single();

      return Task.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST205') {
        _hasCloudTable = false;
        final localTask = Task(
          id: DateTime.now().millisecondsSinceEpoch % 1000000,
          title: cleanTitle,
          done: false,
        );
        _localFallback.insert(0, localTask);
        return localTask;
      }
      rethrow;
    } catch (_) {
      final localTask = Task(
        id: DateTime.now().millisecondsSinceEpoch % 1000000,
        title: cleanTitle,
        done: false,
      );
      _localFallback.insert(0, localTask);
      return localTask;
    }
  }

  Future<Task> updateTask(int id, bool done) async {
    if (!_hasCloudTable) {
      final idx = _localFallback.indexWhere((t) => t.id == id);
      if (idx != -1) {
        final updated = Task(id: id, title: _localFallback[idx].title, done: done);
        _localFallback[idx] = updated;
        return updated;
      }
      return Task(id: id, title: 'Task', done: done);
    }
    try {
      final response = await _client
          .from('tasks')
          .update({'done': done})
          .eq('id', id)
          .select()
          .single();

      return Task.fromJson(response);
    } catch (_) {
      final idx = _localFallback.indexWhere((t) => t.id == id);
      if (idx != -1) {
        final updated = Task(id: id, title: _localFallback[idx].title, done: done);
        _localFallback[idx] = updated;
        return updated;
      }
      return Task(id: id, title: 'Task', done: done);
    }
  }

  Future<void> deleteTask(int id) async {
    if (!_hasCloudTable) {
      _localFallback.removeWhere((t) => t.id == id);
      return;
    }
    try {
      await _client.from('tasks').delete().eq('id', id);
    } catch (_) {
      _localFallback.removeWhere((t) => t.id == id);
    }
  }
}
