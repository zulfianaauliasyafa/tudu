import 'package:taskly/domain/entities/task_entity.dart';

class TaskModel extends TaskEntity {
  TaskModel({
    required String id,
    required String title,
    required String description,
    required bool isCompleted,
    required DateTime dueDate,
  }) : super(
          id: id,
          title: title,
          description: description,
          isCompleted: isCompleted,
          dueDate: dueDate,
        );

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description:
          json['description'] as String? ?? json['notes'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : json['timestamp'] != null
              ? DateTime.parse(json['timestamp'] as String)
              : DateTime.now().add(const Duration(days: 1)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'dueDate': dueDate.toIso8601String(),
    };
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? dueDate,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
    );
  }
}
