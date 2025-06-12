import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:taskly/data/models/task_model.dart';
import 'package:taskly/domain/entities/task_entity.dart';
import 'package:taskly/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final FirebaseAuth firebaseAuth;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  TaskRepositoryImpl({required this.firebaseAuth});

  @override
  Future<List<TaskEntity>> getTasks() async {
    final userId = firebaseAuth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final snapshot = await _database.child('tasks').child(userId).get();
    if (!snapshot.exists) return [];

    final tasks = <TaskEntity>[];
    final map = snapshot.value as Map<dynamic, dynamic>;
    
    map.forEach((key, value) {
      final taskMap = Map<String, dynamic>.from(value as Map);
      taskMap['id'] = key;
      tasks.add(TaskModel.fromJson(taskMap));
    });

    return tasks;
  }

  @override
  Future<void> addTask(TaskEntity task) async {
    final userId = firebaseAuth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final taskModel = task as TaskModel;
    await _database
        .child('tasks')
        .child(userId)
        .child(task.id)
        .set(taskModel.toJson());
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    final userId = firebaseAuth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final taskModel = task as TaskModel;
    await _database
        .child('tasks')
        .child(userId)
        .child(task.id)
        .update(taskModel.toJson());
  }

  @override
  Future<void> deleteTask(String taskId) async {
    final userId = firebaseAuth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    await _database.child('tasks').child(userId).child(taskId).remove();
  }
} 