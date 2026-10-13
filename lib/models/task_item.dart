import 'package:cloud_firestore/cloud_firestore.dart';

class TaskItem {
  const TaskItem({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.isCompleted,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final int priority;
  final bool isCompleted;
  final DateTime createdAt;

  factory TaskItem.fromFirestore(String id, Map<String, dynamic> data) {
    DateTime readDate(Object? value, DateTime fallback) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return fallback;
    }

    final now = DateTime.now();
    return TaskItem(
      id: id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      dueDate: readDate(data['dueDate'], now),
      priority: (data['priority'] as num?)?.toInt() ?? 1,
      isCompleted: data['isCompleted'] as bool? ?? false,
      createdAt: readDate(data['createdAt'], now),
    );
  }
}

String priorityLabel(int priority) => switch (priority) {
  2 => 'High',
  0 => 'Low',
  _ => 'Medium',
};
