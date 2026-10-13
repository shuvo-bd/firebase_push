import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../models/task_item.dart';
import '../services/notification_service.dart';
import '../services/task_controller.dart';
import '../widgets/task_editor_sheet.dart';
import '../widgets/task_tile.dart';

enum TaskFilter { all, pending, completed }

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({
    required this.userId,
    required this.firebaseEnabled,
    required this.onSignOut,
    super.key,
  });

  final String? userId;
  final bool firebaseEnabled;
  final Future<void> Function() onSignOut;

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  late final TaskController _tasks;
  final _searchController = TextEditingController();
  TaskFilter _filter = TaskFilter.all;
  String? _pendingTaskId;
  bool _openingTask = false;

  @override
  void initState() {
    super.initState();
    _tasks = TaskController(userId: widget.userId);
    _searchController.addListener(_refresh);
    final notifications = NotificationService.instance;
    notifications.onTaskOpened = _openTaskFromNotification;
    _pendingTaskId = notifications.pendingTaskId;
    _tasks.addListener(_tryOpenPendingTask);
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryOpenPendingTask());
  }

  @override
  void dispose() {
    _tasks.removeListener(_tryOpenPendingTask);
    _tasks.dispose();
    _searchController
      ..removeListener(_refresh)
      ..dispose();
    if (NotificationService.instance.onTaskOpened ==
        _openTaskFromNotification) {
      NotificationService.instance.onTaskOpened = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _tasks,
      builder: (context, _) {
        final allTasks = _tasks.tasks;
        final visibleTasks = _visibleTasks(allTasks);
        final completedCount = allTasks
            .where((task) => task.isCompleted)
            .length;
        final pendingCount = allTasks.length - completedCount;

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(22, 15, 22, 20),
                        sliver: SliverList.list(
                          children: [
                            _topBar(),
                            const SizedBox(height: 28),
                            Text(
                              _dateHeading(),
                              style: const TextStyle(
                                color: AppColors.green,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              'Your day, in focus.',
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(fontSize: 27),
                            ),
                            const SizedBox(height: 18),
                            _progressSummary(
                              allTasks.length,
                              pendingCount,
                              completedCount,
                            ),
                            const SizedBox(height: 24),
                            TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                hintText: 'Find a task',
                                prefixIcon: Icon(Icons.search),
                                isDense: true,
                              ),
                            ),
                            const SizedBox(height: 14),
                            SegmentedButton<TaskFilter>(
                              showSelectedIcon: false,
                              segments: const [
                                ButtonSegment(
                                  value: TaskFilter.all,
                                  label: Text('All'),
                                ),
                                ButtonSegment(
                                  value: TaskFilter.pending,
                                  label: Text('To do'),
                                ),
                                ButtonSegment(
                                  value: TaskFilter.completed,
                                  label: Text('Done'),
                                ),
                              ],
                              selected: {_filter},
                              onSelectionChanged: (selection) =>
                                  setState(() => _filter = selection.first),
                            ),
                            const SizedBox(height: 22),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _filter == TaskFilter.completed
                                        ? 'Completed'
                                        : _filter == TaskFilter.pending
                                        ? 'Up next'
                                        : 'Your tasks',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge,
                                  ),
                                ),
                                Text(
                                  '${visibleTasks.length} ${visibleTasks.length == 1 ? 'task' : 'tasks'}',
                                  style: const TextStyle(
                                    color: AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                            if (_tasks.errorMessage != null) ...[
                              const SizedBox(height: 10),
                              Text(
                                _tasks.errorMessage!,
                                style: const TextStyle(color: AppColors.coral),
                              ),
                            ],
                            const SizedBox(height: 12),
                            if (visibleTasks.isEmpty)
                              _emptyState()
                            else
                              ...visibleTasks.map(
                                (task) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: TaskTile(
                                    task: task,
                                    onTap: () => _openEditor(task),
                                    onToggle: () =>
                                        _tasks.toggleCompleted(task),
                                    onDelete: () => _confirmDelete(task),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (!widget.firebaseEnabled)
                  const Padding(
                    padding: EdgeInsets.fromLTRB(22, 0, 22, 5),
                    child: Text(
                      'Offline preview · Tasks stay on this device session',
                      style: TextStyle(color: AppColors.muted, fontSize: 11),
                    ),
                  ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openEditor(null),
            backgroundColor: AppColors.greenDark,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('New task'),
          ),
        );
      },
    );
  }

  Widget _topBar() => Row(
    children: [
      Container(
        width: 37,
        height: 37,
        decoration: BoxDecoration(
          color: AppColors.green,
          borderRadius: BorderRadius.circular(11),
        ),
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 22),
      ),
      const SizedBox(width: 10),
      const Expanded(
        child: Text(
          'daymark',
          style: TextStyle(
            color: AppColors.ink,
            fontWeight: FontWeight.w800,
            fontSize: 17,
          ),
        ),
      ),
      if (!widget.firebaseEnabled)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.greenSoft,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'PREVIEW',
            style: TextStyle(
              color: AppColors.greenDark,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      const SizedBox(width: 8),
      IconButton(
        tooltip: 'Sign out',
        onPressed: widget.onSignOut,
        icon: const Icon(Icons.logout_rounded, color: AppColors.muted),
      ),
    ],
  );

  Widget _progressSummary(int total, int pending, int completed) {
    final progress = total == 0 ? 0.0 : completed / total;
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.greenDark,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'A steady start',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '$completed / $total done',
                style: const TextStyle(color: Color(0xFFD8E6E0), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 13),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: const Color(0xFF628277),
              color: const Color(0xFFF0C879),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$pending tasks still in motion',
            style: const TextStyle(color: Color(0xFFD8E6E0), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 30),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.line),
    ),
    child: Column(
      children: [
        const Icon(Icons.spa_outlined, size: 30, color: AppColors.green),
        const SizedBox(height: 10),
        Text(
          _searchController.text.isNotEmpty
              ? 'No matches yet'
              : 'A little breathing room',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Add a task when something comes to mind.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.muted, fontSize: 13),
        ),
      ],
    ),
  );

  List<TaskItem> _visibleTasks(List<TaskItem> tasks) {
    final query = _searchController.text.trim().toLowerCase();
    return tasks.where((task) {
      final matchesFilter = switch (_filter) {
        TaskFilter.all => true,
        TaskFilter.pending => !task.isCompleted,
        TaskFilter.completed => task.isCompleted,
      };
      final matchesQuery =
          query.isEmpty ||
          task.title.toLowerCase().contains(query) ||
          task.description.toLowerCase().contains(query);
      return matchesFilter && matchesQuery;
    }).toList();
  }

  String _dateHeading() {
    final now = DateTime.now();
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${weekdays[now.weekday - 1].toUpperCase()}  ·  ${months[now.month - 1]} ${now.day}';
  }

  void _refresh() => setState(() {});

  Future<void> _openEditor(TaskItem? task) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.canvas,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) => TaskEditorSheet(
        initialTask: task,
        onSave:
            ({
              required title,
              required description,
              required dueDate,
              required priority,
              required isCompleted,
            }) => _tasks.saveTask(
              existing: task,
              title: title,
              description: description,
              dueDate: dueDate,
              priority: priority,
              isCompleted: isCompleted,
            ),
      ),
    );
  }

  Future<void> _confirmDelete(TaskItem task) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this task?'),
        content: Text('“${task.title}” will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep task'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (shouldDelete == true) await _tasks.deleteTask(task);
  }

  void _openTaskFromNotification(String? taskId) {
    if (taskId == null) return;
    _pendingTaskId = taskId;
    _tryOpenPendingTask();
  }

  void _tryOpenPendingTask() {
    if (!mounted || _openingTask || _pendingTaskId == null) return;
    TaskItem? task;
    for (final item in _tasks.tasks) {
      if (item.id == _pendingTaskId) {
        task = item;
        break;
      }
    }
    if (task == null) return;
    _openingTask = true;
    _pendingTaskId = null;
    NotificationService.instance.pendingTaskId = null;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) await _openEditor(task);
      _openingTask = false;
    });
  }
}
