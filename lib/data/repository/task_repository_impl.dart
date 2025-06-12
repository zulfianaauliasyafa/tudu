import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:taskly/data/models/task_model.dart';
import 'package:taskly/domain/entities/task_entity.dart';
import 'package:taskly/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final FirebaseAuth firebaseAuth;
  late final DatabaseReference _database;

  TaskRepositoryImpl({required this.firebaseAuth}) {
    _database = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
          "https://project-akhir-pam-4f1a1-default-rtdb.asia-southeast1.firebasedatabase.app",
    ).ref();
    print(
        'TaskRepository: Database initialized with URL: ${_database.root.toString()}');
  }

  @override
  Future<List<TaskEntity>> getTasks() async {
    try {
      print('TaskRepository: Getting tasks');
      final userId = firebaseAuth.currentUser?.uid;
      print('TaskRepository: Current user ID: $userId');

      if (userId == null) {
        print('TaskRepository: User not authenticated');
        throw Exception('User not authenticated');
      }

      final taskRef = _database.child('tasks').child(userId);
      print('TaskRepository: Task reference path: ${taskRef.path}');

      final snapshot = await taskRef.get();
      print('TaskRepository: Database snapshot exists: ${snapshot.exists}');

      if (!snapshot.exists) {
        print('TaskRepository: No tasks found');
        return [];
      }

      final tasks = <TaskEntity>[];
      final map = snapshot.value as Map<dynamic, dynamic>;
      print('TaskRepository: Raw data from database: $map');

      map.forEach((key, value) {
        try {
          print('TaskRepository: Processing task $key');
          final taskMap = Map<String, dynamic>.from(value as Map);
          taskMap['id'] = key;
          print('TaskRepository: Task data: $taskMap');
          tasks.add(TaskModel.fromJson(taskMap));
          print('TaskRepository: Task added successfully');
        } catch (e, stackTrace) {
          print('TaskRepository: Error parsing task $key: $e');
          print('TaskRepository: Stack trace: $stackTrace');
        }
      });

      print('TaskRepository: Total tasks loaded: ${tasks.length}');
      return tasks;
    } catch (e, stackTrace) {
      print('TaskRepository: Error getting tasks: $e');
      print('TaskRepository: Stack trace: $stackTrace');
      throw Exception('Failed to get tasks: $e');
    }
  }

  @override
  Future<void> addTask(TaskEntity task) async {
    try {
      print('TaskRepository: Adding task: ${task.title}');
      final userId = firebaseAuth.currentUser?.uid;
      print('TaskRepository: Current user ID: $userId');

      if (userId == null) {
        print('TaskRepository: User not authenticated');
        throw Exception('User not authenticated');
      }

      final taskModel = task as TaskModel;
      final taskRef = _database.child('tasks').child(userId).child(task.id);
      print('TaskRepository: Task reference path: ${taskRef.path}');

      final taskData = taskModel.toJson();
      print('TaskRepository: Task data to save: $taskData');

      await taskRef.set(taskData);
      print('TaskRepository: Task added successfully');
    } catch (e, stackTrace) {
      print('TaskRepository: Error adding task: $e');
      print('TaskRepository: Stack trace: $stackTrace');
      throw Exception('Failed to add task: $e');
    }
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    try {
      final userId = firebaseAuth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      final taskModel = task as TaskModel;
      final taskRef = _database.child('tasks').child(userId).child(task.id);

      await taskRef.update(taskModel.toJson());
    } catch (e) {
      print('Error updating task: $e');
      throw Exception('Failed to update task: $e');
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    try {
      final userId = firebaseAuth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      await _database.child('tasks').child(userId).child(taskId).remove();
    } catch (e) {
      print('Error deleting task: $e');
      throw Exception('Failed to delete task: $e');
    }
  }
}
