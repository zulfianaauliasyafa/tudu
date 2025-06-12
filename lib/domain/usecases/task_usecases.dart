import 'package:taskly/domain/entities/task_entity.dart';
import 'package:taskly/domain/repositories/task_repository.dart';

class TaskUseCases {
  final TaskRepository repository;

  TaskUseCases({required this.repository});

  Future<List<TaskEntity>> getTasks() async {
    return await repository.getTasks();
  }

  Future<void> addTask(TaskEntity task) async {
    await repository.addTask(task);
  }

  Future<void> updateTask(TaskEntity task) async {
    await repository.updateTask(task);
  }

  Future<void> deleteTask(String taskId) async {
    await repository.deleteTask(taskId);
  }
} 