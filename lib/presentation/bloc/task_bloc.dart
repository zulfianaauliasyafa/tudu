import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/usecases/task_usecases.dart';
import '../../data/models/task_model.dart';

// Events
abstract class TaskEvent {}

class LoadTasks extends TaskEvent {}

class AddTask extends TaskEvent {
  final TaskEntity task;
  AddTask(this.task);
}

class UpdateTask extends TaskEvent {
  final TaskEntity task;
  UpdateTask(this.task);
}

class DeleteTask extends TaskEvent {
  final String taskId;
  DeleteTask(this.taskId);
}

// States
abstract class TaskState {}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<TaskEntity> tasks;
  TaskLoaded(this.tasks);
}

class TaskError extends TaskState {
  final String message;
  TaskError(this.message);
}

// BLoC
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskUseCases taskUseCases;

  TaskBloc({required this.taskUseCases}) : super(TaskInitial()) {
    // Load Tasks
    on<LoadTasks>((event, emit) async {
      try {
        print('TaskBloc: Starting to load tasks');
        emit(TaskLoading());

        // Tunggu sedikit untuk memastikan Firebase sudah siap
        await Future.delayed(const Duration(milliseconds: 500));

        final tasks = await taskUseCases.getTasks();
        print('TaskBloc: Tasks loaded successfully. Count: ${tasks.length}');
        if (tasks.isNotEmpty) {
          print('TaskBloc: First task: ${tasks.first.title}');
        }
        emit(TaskLoaded(tasks));
      } catch (e, stackTrace) {
        print('TaskBloc: Error loading tasks: $e');
        print('TaskBloc: Stack trace: $stackTrace');
        emit(TaskError('Gagal memuat task: $e'));
      }
    });

    // Add Task
    on<AddTask>((event, emit) async {
      try {
        print('TaskBloc: Starting to add task: ${event.task.title}');
        emit(TaskLoading());

        // Validasi task
        if (event.task.title.isEmpty) {
          throw Exception('Judul task tidak boleh kosong');
        }

        await taskUseCases.addTask(event.task);
        print('TaskBloc: Task added successfully');

        // Tunggu sedikit untuk memastikan data tersimpan
        await Future.delayed(const Duration(milliseconds: 500));

        final tasks = await taskUseCases.getTasks();
        print('TaskBloc: Tasks reloaded. Count: ${tasks.length}');
        if (tasks.isNotEmpty) {
          print('TaskBloc: First task after add: ${tasks.first.title}');
        }
        emit(TaskLoaded(tasks));
      } catch (e, stackTrace) {
        print('TaskBloc: Error adding task: $e');
        print('TaskBloc: Stack trace: $stackTrace');
        emit(TaskError('Gagal menambah task: $e'));
      }
    });

    // Update Task
    on<UpdateTask>((event, emit) async {
      try {
        print('TaskBloc: Starting to update task: ${event.task.title}');
        emit(TaskLoading());

        // Pastikan task adalah TaskModel
        if (event.task is! TaskModel) {
          print('TaskBloc: Converting TaskEntity to TaskModel');
          final taskModel = TaskModel(
            id: event.task.id,
            title: event.task.title,
            description: event.task.description,
            isCompleted: event.task.isCompleted,
            dueDate: event.task.dueDate,
          );
          await taskUseCases.updateTask(taskModel);
        } else {
          await taskUseCases.updateTask(event.task);
        }

        print('TaskBloc: Task updated successfully');

        // Tunggu sedikit untuk memastikan data tersimpan
        await Future.delayed(const Duration(milliseconds: 500));

        final tasks = await taskUseCases.getTasks();
        print('TaskBloc: Tasks reloaded. Count: ${tasks.length}');
        if (tasks.isNotEmpty) {
          print('TaskBloc: First task after update: ${tasks.first.title}');
        }
        emit(TaskLoaded(tasks));
      } catch (e, stackTrace) {
        print('TaskBloc: Error updating task: $e');
        print('TaskBloc: Stack trace: $stackTrace');
        emit(TaskError('Gagal mengupdate task: $e'));
      }
    });

    // Delete Task
    on<DeleteTask>((event, emit) async {
      try {
        emit(TaskLoading());
        await taskUseCases.deleteTask(event.taskId);
        final tasks = await taskUseCases.getTasks();
        emit(TaskLoaded(tasks));
      } catch (e) {
        emit(TaskError(e.toString()));
      }
    });
  }
}
