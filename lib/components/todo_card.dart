import 'package:flutter/material.dart';

class TodoCard extends StatelessWidget {
  const TodoCard({
    super.key,
    required this.taskName, required this.taskCompleted, this.onChanged});

  final String taskName;
  final bool taskCompleted;
  final Function(bool?)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 15,
        right: 25,
        bottom: 0,
        left: 25,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Checkbox(
              value: taskCompleted,
              onChanged: onChanged,
              checkColor: Colors.white,
              activeColor: const Color(0xFF4169E1),
              side: const BorderSide(color: Color(0xFFA8A8A8)),
            ),
            Text(
              taskName,
              style: TextStyle(
                color: const Color(0xFF3E3E3E),
                fontSize: 16,
                decoration: taskCompleted 
                  ? TextDecoration.lineThrough 
                  : TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}