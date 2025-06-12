import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskly/presentation/bloc/auth_bloc.dart';
import 'package:taskly/presentation/bloc/task_bloc.dart';
import 'package:taskly/presentation/pages/addtask_page.dart';
import 'package:taskly/presentation/pages/edittask_page.dart';
import 'package:taskly/presentation/pages/login_page.dart';
import 'package:taskly/components/todo_card.dart';
import 'package:taskly/domain/entities/task_entity.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLogoutVisible = false;

  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(LoadTasks());
  }

  void _toggleLogoutButton() {
    setState(() {
      _isLogoutVisible = !_isLogoutVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
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
          BlocBuilder<TaskBloc, TaskState>(
            builder: (context, state) {
              if (state is TaskLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is TaskLoaded) {
                final tasks = state.tasks;
                final completedTasks = tasks.where((task) => task.isCompleted).length;
                final completionRate = tasks.isEmpty ? 0.0 : completedTasks / tasks.length;

                return ListView(
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
                                '${(completionRate * 100).toStringAsFixed(0)}% Task Completed',
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
                                  value: completionRate,
                                  backgroundColor: Colors.grey[200],
                                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4169E1)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Column(
                        children: [
                          for (var task in tasks)
                            TodoCard(
                              taskTitle: task.title,
                              taskNotes: task.description,
                              taskCompleted: task.isCompleted,
                              onChanged: (value) {
                                if (value != null) {
                                  context.read<TaskBloc>().add(
                                    UpdateTask(
                                      task.copyWith(isCompleted: value),
                                    ),
                                  );
                                }
                              },
                              onEditPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditTaskPage(
                                      taskId: task.id,
                                      title: task.title,
                                      notes: task.description,
                                    ),
                                  ),
                                );
                              },
                              onDeletePressed: () {
                                context.read<TaskBloc>().add(DeleteTask(task.id));
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              } else if (state is TaskError) {
                return Center(child: Text(state.message));
              }
              return const Center(child: Text('No tasks found'));
            },
          ),
          if (_isLogoutVisible)
            Positioned(
              top: 0,
              right: 25,
              child: Card(
                child: TextButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(SignOutEvent());
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                  child: const Text('Logout'),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTaskPage()),
          );
        },
        backgroundColor: const Color(0xFF4169E1),
        child: SvgPicture.asset(
          'images/plus.svg',
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
      ),
    );
  }
}
