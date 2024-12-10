import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class TaskProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _tasks = [];

  List<Map<String, dynamic>> get tasks => _tasks;

  double get completionRate {
    if (_tasks.isEmpty) return 0.0;
    int completedTasks = _tasks.where((task) => task['completed'] == true).length;
    return completedTasks / _tasks.length;
  }

  Future<void> fetchTasksFromDatabase() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User is not logged in!');
      }

      final uid = user.uid;
      final taskRef = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: "https://project-akhir-pam-4f1a1-default-rtdb.asia-southeast1.firebasedatabase.app",
      ).ref().child('tasks').child(uid);

      taskRef.onValue.listen((event) {
        final data = event.snapshot.value as Map?;
        final List<Map<String, dynamic>> fetchedTasks = [];

        if (data != null) {
          data.forEach((taskId, value) {
            fetchedTasks.add({
              'id': taskId,
              'title': value['title'],
              'notes': value['notes'],
              'timestamp': value['timestamp'],
              'completed': value['completed'] ?? false,
            });
          });
        }

        _tasks = fetchedTasks;
        notifyListeners();
      });
    } catch (e) {
      throw Exception('Failed to fetch tasks: $e');
    }
  }

  Future<void> updateTaskCompletion(String taskId, bool isCompleted) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User is not logged in!');
      }

      final uid = user.uid;
      final taskRef = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: "https://project-akhir-pam-4f1a1-default-rtdb.asia-southeast1.firebasedatabase.app",
      ).ref().child('tasks').child(uid).child(taskId);

      await taskRef.update({'completed': isCompleted});

      _tasks.firstWhere((task) => task['id'] == taskId)['completed'] = isCompleted;
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }
}
