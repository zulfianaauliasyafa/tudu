import 'package:firebase_auth/firebase_auth.dart';
import 'package:taskly/data/models/auth_model.dart';
import 'package:taskly/domain/entities/auth_entity.dart';
import 'package:taskly/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth;

  AuthRepositoryImpl({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  @override
  Future<Map<String, dynamic>> signUp(String email, String password) async {
    try {
      print('Starting registration process for email: $email');
      
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      print('Firebase response received');
      
      if (credential.user != null) {
        print('User created successfully: ${credential.user!.uid}');
        return {
          'success': true,
          'user': AuthModel.fromFirebaseUser(credential.user!),
          'message': 'Registration successful'
        };
      } else {
        print('User creation failed: credential.user is null');
        return {
          'success': false,
          'message': 'Registration failed - no user created'
        };
      }
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException during registration: ${e.code} - ${e.message}');
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'The password provided is too weak';
          break;
        case 'email-already-in-use':
          message = 'An account already exists for that email';
          break;
        case 'invalid-email':
          message = 'The email address is not valid';
          break;
        case 'operation-not-allowed':
          message = 'Email/password accounts are not enabled';
          break;
        default:
          message = 'An error occurred during registration: ${e.message}';
      }
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      print('Unexpected error during registration: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred: $e',
      };
    }
  }

  @override
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        return {
          'success': true,
          'user': AuthModel.fromFirebaseUser(credential.user!),
          'message': 'Login successful'
        };
      } else {
        return {
          'success': false,
          'message': 'Login failed'
        };
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found for that email';
          break;
        case 'wrong-password':
          message = 'Wrong password provided';
          break;
        case 'user-disabled':
          message = 'This account has been disabled';
          break;
        case 'invalid-email':
          message = 'The email address is not valid';
          break;
        default:
          message = 'An error occurred during login';
      }
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred',
      };
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  AuthEntity? getCurrentUser() {
    final user = _auth.currentUser;
    if (user != null) {
      return AuthModel.fromFirebaseUser(user);
    }
    return null;
  }
} 