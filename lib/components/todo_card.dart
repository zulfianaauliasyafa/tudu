import 'package:flutter/material.dart';

class TodoCard extends StatelessWidget {
  final String taskTitle;
  final String taskNotes;
  final bool taskCompleted;
  final void Function(bool?)? onChanged;
  final VoidCallback? onEditPressed;
  final VoidCallback? onDeletePressed;

  const TodoCard({
    super.key,
    required this.taskTitle,
    required this.taskNotes,
    required this.taskCompleted,
    required this.onChanged,
    this.onEditPressed,
    this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Checkbox(
              value: taskCompleted,
              onChanged: onChanged,
              activeColor: const Color(0xFF4169E1),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    taskTitle,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      decoration: taskCompleted ? TextDecoration.lineThrough : null,
                      color: taskCompleted ? Colors.grey : const Color(0xFF202020),
                    ),
                  ),
                  if (taskNotes.isNotEmpty)
                    Text(
                      taskNotes,
                      style: TextStyle(
                        fontSize: 14,
                        color: taskCompleted ? Colors.grey : const Color(0xFF656565),
                        decoration: taskCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                ],
              ),
            ),
            Row(
              children: [
                if (onEditPressed != null)
                  IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFF4169E1)),
                    onPressed: onEditPressed,
                  ),
                if (onDeletePressed != null)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onDeletePressed,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}