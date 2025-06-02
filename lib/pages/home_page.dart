import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:taskly/pages/addtask_page.dart';
import 'package:taskly/pages/edittask_page.dart';
import 'package:taskly/pages/login_page.dart';
import 'package:taskly/components/todo_card.dart';
import 'package:taskly/providers/task_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> toDoList = [];
  bool _isLogoutVisible = false;

  @override
  void initState() {
    super.initState();
    _fetchTasksFromDatabase();
  }

  Future<void> _fetchTasksFromDatabase() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
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

        setState(() {
          toDoList = fetchedTasks;
        });
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch tasks: $e')),
      );
    }
  }

  Future<void> checkBoxChanged(int index, bool? value) async {
    if (value == null) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User is not logged in!')),
        );
        return;
      }

      final uid = user.uid;
      final taskId = toDoList[index]['id'];
      final taskRef = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: "https://project-akhir-pam-4f1a1-default-rtdb.asia-southeast1.firebasedatabase.app",
      ).ref().child('tasks').child(uid).child(taskId);

      await taskRef.update({'completed': value});

      setState(() {
      toDoList[index]['completed'] = value;

      toDoList.sort((a, b) {
        if (a['completed'] == b['completed']) return 0;
        return a['completed'] ? 1 : -1; 
      });
    });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update task: $e')),
      );
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to log out: $e')),
      );
    }
  }

  void _toggleLogoutButton() {
    setState(() {
      _isLogoutVisible = !_isLogoutVisible;
    });
  }

  @override
  Widget build(BuildContext context) {

    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FD),
        toolbarHeight: 100,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SvgPicture.asset('images/taskly-home.svg'),
              GestureDetector(
                onTap: _toggleLogoutButton,
                child: Image.asset(
                  'images/profile.png',
                  height: 50,
                  width: 50,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          ListView(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: Colors.white,
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        const Text(
                          'Your Completion',
                          style: TextStyle(fontSize: 14, color: Color(0xFF656565)),
                        ),
                        Text(
                          '${(taskProvider.completionRate * 100).toStringAsFixed(0)}% Task Completed',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF474747),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Container(
                        height: 45,
                        child: LinearProgressIndicator(
                          value: taskProvider.completionRate,
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4169E1)),
                        ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Text(
                  'All Task',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: Color(0xFF202020)),
                ),
              ),
              Column(
                children: toDoList.map((item) {
                  int index = toDoList.indexOf(item);
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditTaskPage(
                            taskId: item['id'],
                            title: item['title'],
                            notes: item['notes'], 
                          ),
                        ),
                      );
                    },
                    child: TodoCard(
                      taskName: item['title'],
                      taskCompleted: item['completed'],
                      onChanged: (value) => checkBoxChanged(index, value),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          if (_isLogoutVisible) ...[
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),
            Center(
              child: GestureDetector(
                onTap: () => _handleLogout(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
      floatingActionButton: _isLogoutVisible
          ? null
          : FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddTaskPage()),
                );
              },
              backgroundColor: const Color(0xFF4169E1),
              child: SvgPicture.asset('images/plus.svg'),
            ),
    );
  }
}
