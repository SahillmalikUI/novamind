class Task {
  final int id;
  final String title;
  final bool done;
  final String createdAt;

  Task({
    required this.id,
    required this.title,
    required this.done,
    this.createdAt = '',
  });

  // Convert JSON from Supabase to Task object
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '',
      done: json['done'] as bool? ?? false,
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  // Convert Task object to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'done': done,
    };
  }
}
