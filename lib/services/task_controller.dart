import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/task_item.dart';

class TaskController extends ChangeNotifier {
  TaskController({required this.userId}) {
    if (userId == null) {
      _tasks = _demoTasks;
    } else {
      _subscription = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen(
            (snapshot) {
              _tasks = snapshot.docs
                  .map((doc) => TaskItem.fromFirestore(doc.id, doc.data()))
                  .toList();
              errorMessage = null;
              notifyListeners();
            },
            onError: (Object error) {
              errorMessage =
                  'Tasks could not be synced. Check Firestore rules.';
              notifyListeners();
            },
          );
    }
  }

  final String? userId;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;
  List<TaskItem> _tasks = const [];
  String? errorMessage;

  static final List<TaskItem> _demoTasks = [
    TaskItem(
      id: 'demo-plan',
      title: 'Prepare weekly plan',
      description: 'Review priorities and map out the week.',
      dueDate: DateTime.now(),
      priority: 2,
      isCompleted: false,
      createdAt: DateTime.now(),
    ),
    TaskItem(
      id: 'demo-assignment',
      title: 'Finish Firebase assignment',
      description: 'Connect authentication, tasks, and notifications.',
      dueDate: DateTime.now().add(const Duration(days: 1)),
      priority: 1,
      isCompleted: false,
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    TaskItem(
      id: 'demo-inbox',
      title: 'Clear the inbox',
      description: 'Reply to the important messages.',
      dueDate: DateTime.now(),
      priority: 0,
      isCompleted: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  List<TaskItem> get tasks => List.unmodifiable(_tasks);

  Future<void> saveTask({
    TaskItem? existing,
    required String title,
    required String description,
    required DateTime dueDate,
    required int priority,
    required bool isCompleted,
  }) async {
    final now = DateTime.now();
    if (userId == null) {
      final task = TaskItem(
        id: existing?.id ?? 'local-${now.microsecondsSinceEpoch}',
        title: title,
        description: description,
        dueDate: dueDate,
        priority: priority,
        isCompleted: isCompleted,
        createdAt: existing?.createdAt ?? now,
      );
      _tasks = [task, ..._tasks.where((item) => item.id != existing?.id)];
      notifyListeners();
      return;
    }

    final collection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('tasks');
    final reference = existing == null
        ? collection.doc()
        : collection.doc(existing.id);
    await reference.set({
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'priority': priority,
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(existing?.createdAt ?? now),
    });
  }

  Future<void> toggleCompleted(TaskItem task) async {
    if (userId == null) {
      _tasks = _tasks
          .map(
            (item) => item.id == task.id
                ? TaskItem(
                    id: item.id,
                    title: item.title,
                    description: item.description,
                    dueDate: item.dueDate,
                    priority: item.priority,
                    isCompleted: !item.isCompleted,
                    createdAt: item.createdAt,
                  )
                : item,
          )
          .toList();
      notifyListeners();
      return;
    }
    await _taskReference(task.id).update({'isCompleted': !task.isCompleted});
  }

  Future<void> deleteTask(TaskItem task) async {
    if (userId == null) {
      _tasks = _tasks.where((item) => item.id != task.id).toList();
      notifyListeners();
      return;
    }
    await _taskReference(task.id).delete();
  }

  DocumentReference<Map<String, dynamic>> _taskReference(String id) =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .doc(id);

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
