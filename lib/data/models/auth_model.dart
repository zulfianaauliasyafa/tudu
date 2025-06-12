import 'package:firebase_auth/firebase_auth.dart';
import 'package:taskly/domain/entities/auth_entity.dart';

class AuthModel extends AuthEntity {
  AuthModel({
    required String uid,
    required String email,
  }) : super(
          uid: uid,
          email: email,
        );

  factory AuthModel.fromFirebaseUser(User user) {
    return AuthModel(
      uid: user.uid,
      email: user.email ?? '',
    );
  }
} 