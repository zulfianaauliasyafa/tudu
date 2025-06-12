import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taskly/data/repository/task_repository_impl.dart';
import 'package:taskly/domain/repositories/task_repository.dart';
import 'package:taskly/domain/usecases/task_usecases.dart';
import 'package:taskly/presentation/bloc/task_bloc.dart';
import 'package:taskly/data/repositories/auth_repository_impl_new.dart';
import 'package:taskly/domain/repositories/auth_repository.dart';
import 'package:taskly/domain/usecases/auth_usecases.dart';
import 'package:taskly/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Bloc
  sl.registerFactory(() => AuthBloc(authUseCases: sl()));
  sl.registerFactory(() => TaskBloc(taskUseCases: sl()));

  // Use cases
  sl.registerLazySingleton(() => AuthUseCases(repository: sl()));
  sl.registerLazySingleton(() => TaskUseCases(repository: sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(auth: sl()));
  sl.registerLazySingleton<TaskRepository>(() => TaskRepositoryImpl(firebaseAuth: sl()));

  // External
  sl.registerLazySingleton(() => FirebaseAuth.instance);
} 