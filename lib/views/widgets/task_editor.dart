import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanbankit/core/utils/helper_functions_utils.dart';
import '../../core/localization/local_keys.dart' show LocalKeys;
import '../../models/task_model.dart';
import '../../core/enums/task_status.dart';

class TaskEditor extends StatefulWidget {
  final Task? task;
  final Function(Task) onTaskSaved;

  const TaskEditor({super.key, this.task, required this.onTaskSaved});

  @override
  State<TaskEditor> createState() => _TaskEditorState();
}

class _TaskEditorState extends State<TaskEditor> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  TaskStatus _selectedStatus = TaskStatus.todo;
  int _selectedPriority = 2;
  DateTime? _selectedDueDate;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _selectedStatus = widget.task!.status;
      _selectedPriority = widget.task!.priority;
      _selectedDueDate = widget.task!.dueDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(20),
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.task != null
                                  ? LocalKeys.editTask.tr
                                  : LocalKeys.newTask.tr,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            labelText: LocalKeys.taskTitle.tr,
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return LocalKeys.pleaseEnterTitle.tr;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            labelText: LocalKeys.taskDescription.tr,
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                          maxLines: 4,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<TaskStatus>(
                          initialValue: _selectedStatus,
                          decoration: InputDecoration(
                            labelText: LocalKeys.taskStatus.tr,
                            border: OutlineInputBorder(),
                          ),
                          items: TaskStatus.values.map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Text(
                                HelperFunctionsUtils.getStatusDisplayName(
                                  status,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedStatus = value;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          initialValue: _selectedPriority,
                          decoration: InputDecoration(
                            labelText: LocalKeys.priority.tr,
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 1,
                              child: Text(LocalKeys.high.tr),
                            ),
                            DropdownMenuItem(
                              value: 2,
                              child: Text(LocalKeys.medium.tr),
                            ),
                            DropdownMenuItem(
                              value: 3,
                              child: Text(LocalKeys.low.tr),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedPriority = value;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: _selectDueDate,
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: LocalKeys.dueDate.tr,
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            child: Text(
                              _selectedDueDate != null
                                  ? '${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}'
                                  : LocalKeys.selectDueDate.tr,
                              style: TextStyle(
                                color: _selectedDueDate != null
                                    ? Colors.black
                                    : Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                        if (_selectedDueDate != null) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  _selectedDueDate = null;
                                });
                              },
                              child: Text(LocalKeys.clearDueDate.tr),
                            ),
                          ),
                        ],
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text(LocalKeys.cancel.tr),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _saveTask,
                                child: Text(
                                  widget.task != null
                                      ? LocalKeys.update.tr
                                      : LocalKeys.create.tr,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final task = Task(
        id: widget.task?.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        status: _selectedStatus,
        createdAt: widget.task?.createdAt ?? DateTime.now(),
        dueDate: _selectedDueDate,
        priority: _selectedPriority,
      );

      widget.onTaskSaved(task);
      Navigator.of(context).pop();
    }
  }
}
