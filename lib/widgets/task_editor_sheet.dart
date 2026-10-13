import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../models/task_item.dart';

class TaskEditorSheet extends StatefulWidget {
  const TaskEditorSheet({
    required this.initialTask,
    required this.onSave,
    super.key,
  });

  final TaskItem? initialTask;
  final Future<void> Function({
    required String title,
    required String description,
    required DateTime dueDate,
    required int priority,
    required bool isCompleted,
  })
  onSave;

  @override
  State<TaskEditorSheet> createState() => _TaskEditorSheetState();
}

class _TaskEditorSheetState extends State<TaskEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late DateTime _dueDate;
  late int _priority;
  late bool _isCompleted;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final task = widget.initialTask;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(
      text: task?.description ?? '',
    );
    _dueDate = task?.dueDate ?? DateTime.now();
    _priority = task?.priority ?? 1;
    _isCompleted = task?.isCompleted ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.initialTask != null;
    return Padding(
      padding: EdgeInsets.only(
        left: 22,
        right: 22,
        top: 18,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 22,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      editing ? 'Edit task' : 'A new task',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _titleController,
                autofocus: !editing,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Task title',
                  hintText: 'What needs to get done?',
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Add a title to continue'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 3,
                minLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Add a little more detail',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _chooseDate,
                      icon: const Icon(Icons.calendar_today_outlined, size: 17),
                      label: Text(_formattedDate(_dueDate)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _priority,
                      decoration: const InputDecoration(labelText: 'Priority'),
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('Low')),
                        DropdownMenuItem(value: 1, child: Text('Medium')),
                        DropdownMenuItem(value: 2, child: Text('High')),
                      ],
                      onChanged: (value) {
                        if (value != null) setState(() => _priority = value);
                      },
                    ),
                  ),
                ],
              ),
              if (editing) ...[
                const SizedBox(height: 8),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _isCompleted,
                  title: const Text('Mark as complete'),
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: AppColors.green,
                  onChanged: (value) =>
                      setState(() => _isCompleted = value ?? false),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _saving ? null : _submit,
                  child: _saving
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(editing ? 'Save changes' : 'Add task'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _chooseDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (date != null) setState(() => _dueDate = date);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await widget.onSave(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dueDate: _dueDate,
        priority: _priority,
        isCompleted: _isCompleted,
      );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save this task. Try again.')),
        );
      }
    }
  }

  String _formattedDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}
