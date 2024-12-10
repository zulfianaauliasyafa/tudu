import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class EditTaskPage extends StatefulWidget {
  final String taskId;
  final String title;
  final String notes;

  EditTaskPage({
    required this.taskId,
    required this.title,
    required this.notes,
  });

  @override
  State<EditTaskPage> createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTaskData();
  }

  Future<void> _loadTaskData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User is not logged in!')),
        );
        return;
      }

      final uid = user.uid;
      final taskRef = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: "https://project-akhir-pam-4f1a1-default-rtdb.asia-southeast1.firebasedatabase.app",
      ).ref().child('tasks').child(uid).child(widget.taskId);

      final taskSnapshot = await taskRef.get();

      if (taskSnapshot.exists) {
        final taskData = taskSnapshot.value as Map<dynamic, dynamic>;
        titleController.text = taskData['title'] ?? '';
        notesController.text = taskData['notes'] ?? '';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load task: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateTask(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User is not logged in!')),
        );
        return;
      }

      final uid = user.uid;
      final taskRef = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: "https://project-akhir-pam-4f1a1-default-rtdb.asia-southeast1.firebasedatabase.app",
      ).ref().child('tasks').child(uid).child(widget.taskId);

      await taskRef.update({
        'title': titleController.text,
        'notes': notesController.text,
      });

      Navigator.pop(context); // Return to the previous screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update task: $e')),
      );
    }
  }

  Future<void> _deleteTask(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User is not logged in!')),
        );
        return;
      }

      final uid = user.uid;
      final taskRef = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: "https://project-akhir-pam-4f1a1-default-rtdb.asia-southeast1.firebasedatabase.app",
      ).ref().child('tasks').child(uid).child(widget.taskId);

      await taskRef.remove();

      Navigator.pop(context); // Return to the previous screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete task: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Edit Task',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.blue),
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                _updateTask(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Task title cannot be empty!'),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Judul',
                      labelStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Catatan',
                      labelStyle: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                      border: InputBorder.none,
                    ),
                    maxLines: null, // Allows multiline input
                    keyboardType: TextInputType.multiline,
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _deleteTask(context),
        backgroundColor: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      bottomNavigationBar: Container(
        height: 8,
        color: Colors.blueGrey[50], // Matches light background tone
      ),
      backgroundColor: const Color(0xFFF7F8FC), // Light grey background
    );
  }
}
