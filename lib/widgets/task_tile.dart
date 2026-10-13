import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../models/task_item.dart';

class TaskTile extends StatelessWidget {
  const TaskTile({
    required this.task,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
    super.key,
  });

  final TaskItem task;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final priorityColor = switch (task.priority) {
      2 => AppColors.coral,
      0 => AppColors.green,
      _ => AppColors.gold,
    };
    final dueLabel =
        task.dueDate.year == DateTime.now().year &&
            task.dueDate.month == DateTime.now().month &&
            task.dueDate.day == DateTime.now().day
        ? 'Today'
        : '${_month(task.dueDate.month)} ${task.dueDate.day}';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: SizedBox.square(
                  dimension: 23,
                  child: Checkbox(
                    value: task.isCompleted,
                    onChanged: (_) => onToggle(),
                    activeColor: AppColors.green,
                    shape: const CircleBorder(),
                    side: const BorderSide(
                      color: Color(0xFFBAC4BE),
                      width: 1.5,
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: task.isCompleted
                            ? AppColors.muted
                            : AppColors.ink,
                      ),
                    ),
                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: AppColors.muted),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.event_outlined,
                          size: 14,
                          color: AppColors.muted,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          dueLabel,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: AppColors.muted),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: priorityColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          priorityLabel(task.priority),
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: AppColors.muted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Task actions',
                icon: const Icon(Icons.more_horiz, color: AppColors.muted),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                onSelected: (value) {
                  if (value == 'delete') onDelete();
                  if (value == 'edit') onTap();
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit task')),
                  PopupMenuItem(value: 'delete', child: Text('Delete task')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _month(int month) => const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][month - 1];
}
