import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskly/domain/entities/task_entity.dart';
import 'package:taskly/domain/usecases/task_usecases.dart';

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
        emit(TaskLoading());
        final tasks = await taskUseCases.getTasks();
        emit(TaskLoaded(tasks));
      } catch (e) {
        emit(TaskError(e.toString()));
      }
    });

    // Add Task
    on<AddTask>((event, emit) async {
      try {
        emit(TaskLoading());
        await taskUseCases.addTask(event.task);
        final tasks = await taskUseCases.getTasks();
        emit(TaskLoaded(tasks));
      } catch (e) {
        emit(TaskError(e.toString()));
      }
    });

    // Update Task
    on<UpdateTask>((event, emit) async {
      try {
        emit(TaskLoading());
        await taskUseCases.updateTask(event.task);
        final tasks = await taskUseCases.getTasks();
        emit(TaskLoaded(tasks));
      } catch (e) {
        emit(TaskError(e.toString()));
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