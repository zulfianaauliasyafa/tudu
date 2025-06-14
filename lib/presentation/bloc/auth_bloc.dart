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
      try {
        print('Checking auth status...');
        emit(AuthLoading());

        // Tunggu Firebase diinisialisasi
        await Future.delayed(const Duration(seconds: 1));

        final currentUser = authUseCases.getCurrentUser();
        print('Current user status: ${currentUser?.email ?? 'null'}');

        if (currentUser != null && currentUser.email.isNotEmpty) {
          print('User is authenticated: ${currentUser.email}');
          emit(Authenticated(currentUser));
        } else {
          print('No authenticated user found');
          emit(Unauthenticated());
        }
      } catch (e) {
        print('Error checking auth status: $e');
        emit(Unauthenticated());
      }
    });

    // Sign Up
    on<SignUpEvent>((event, emit) async {
      try {
        print('Starting sign up process...');
        emit(AuthLoading());

        final result = await authUseCases.signUp(event.email, event.password);
        print('Sign up result: ${result['success']}');

        if (result['success']) {
          final user = result['user'] as AuthEntity;
          print('User registered successfully: ${user.email}');
          emit(Authenticated(user));
        } else {
          print('Registration failed: ${result['message']}');
          emit(AuthError(result['message']));
        }
      } catch (e) {
        print('Unexpected error during sign up: $e');
        emit(AuthError('An unexpected error occurred during registration'));
      }
    });

    // Sign In
    on<SignInEvent>((event, emit) async {
      try {
        print('Starting sign in process...');
        emit(AuthLoading());

        final result = await authUseCases.signIn(event.email, event.password);
        print('Sign in result: ${result['success']}');
        print('Sign in result type: ${result.runtimeType}');
        print('User data type: ${result['user']?.runtimeType}');
        print('User data: ${result['user']}');

        if (result['success']) {
          if (result['user'] is AuthEntity) {
            final user = result['user'] as AuthEntity;
            print('User logged in successfully: ${user.email}');
            emit(Authenticated(user));
          } else {
            print('Invalid user data type: ${result['user']?.runtimeType}');
            emit(AuthError('Invalid user data format'));
          }
        } else {
          print('Login failed: ${result['message']}');
          emit(AuthError(result['message']));
        }
      } catch (e, stackTrace) {
        print('Unexpected error during sign in: $e');
        print('Stack trace: $stackTrace');
        emit(AuthError('An unexpected error occurred during login'));
      }
    });

    // Sign Out
    on<SignOutEvent>((event, emit) async {
      try {
        print('Starting sign out process...');
        emit(AuthLoading());

        await authUseCases.signOut();
        print('User signed out successfully');

        emit(Unauthenticated());
      } catch (e) {
        print('Error during sign out: $e');
        emit(AuthError('Failed to sign out'));
      }
    });
  }
}
