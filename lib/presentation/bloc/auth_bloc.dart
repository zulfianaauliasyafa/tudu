import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskly/domain/entities/auth_entity.dart';
import 'package:taskly/domain/usecases/auth_usecases.dart';

// Events
abstract class AuthEvent {}

class SignUpEvent extends AuthEvent {
  final String email;
  final String password;

  SignUpEvent({required this.email, required this.password});
}

class SignInEvent extends AuthEvent {
  final String email;
  final String password;

  SignInEvent({required this.email, required this.password});
}

class SignOutEvent extends AuthEvent {}

class CheckAuthStatusEvent extends AuthEvent {}

// States
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final AuthEntity user;
  Authenticated(this.user);
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthUseCases authUseCases;

  AuthBloc({required this.authUseCases}) : super(AuthInitial()) {
    // Check Auth Status
    on<CheckAuthStatusEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final currentUser = authUseCases.getCurrentUser();
        await Future.delayed(const Duration(milliseconds: 500)); // Give Firebase time to initialize
        if (currentUser != null) {
          emit(Authenticated(currentUser));
        } else {
          emit(Unauthenticated());
        }
      } catch (e) {
        emit(Unauthenticated());
      }
    });

    // Sign Up
    on<SignUpEvent>((event, emit) async {
      emit(AuthLoading());
      final result = await authUseCases.signUp(event.email, event.password);
      
      if (result['success']) {
        final user = authUseCases.getCurrentUser();
        if (user != null) {
          emit(Authenticated(user));
        } else {
          emit(AuthError('User registration successful but failed to get user data'));
        }
      } else {
        emit(AuthError(result['message']));
      }
    });

    // Sign In
    on<SignInEvent>((event, emit) async {
      emit(AuthLoading());
      final result = await authUseCases.signIn(event.email, event.password);
      
      if (result['success']) {
        final user = authUseCases.getCurrentUser();
        if (user != null) {
          emit(Authenticated(user));
        } else {
          emit(AuthError('Login successful but failed to get user data'));
        }
      } else {
        emit(AuthError(result['message']));
      }
    });

    // Sign Out
    on<SignOutEvent>((event, emit) async {
      emit(AuthLoading());
      await authUseCases.signOut();
      emit(Unauthenticated());
    });
  }
} 