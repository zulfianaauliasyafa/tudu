import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class AddTaskPage extends StatelessWidget {
  AddTaskPage({super.key});

  final TextEditingController titleController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  // Save task to Firebase Realtime Database
  Future<void> _saveTaskToDatabase(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // If user is not logged in
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User is not logged in!'),
          ),
        );
        return;
      }

      final uid = user.uid;
      final taskRef = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
      "https://project-akhir-pam-4f1a1-default-rtdb.asia-southeast1.firebasedatabase.app",)
      .ref()
      .child('tasks')
      .child(uid);

      final task = {
        'title': titleController.text,
        'notes': notesController.text,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await taskRef.push().set(task); // Save the task under a unique key

      Navigator.pop(context); // Return to the previous screen
    } catch (e) {
      // Handle errors gracefully
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save task: $e'),
        ),
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
          'Add Task',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.blue),
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                _saveTaskToDatabase(context);
              } else {
                // Show a message if the task title is empty
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
      body: Padding(
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
      bottomNavigationBar: Container(
        height: 8,
        color: Colors.blueGrey[50], // Matches light background tone
      ),
      backgroundColor: const Color(0xFFF7F8FC), // Light grey background
    );
  }
}
