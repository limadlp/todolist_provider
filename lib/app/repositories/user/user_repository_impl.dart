import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo_list_provider/app/exceptions/auth_exception.dart';
import 'dart:developer';
import './user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseAuth _firebaseAuth;
  UserRepositoryImpl({required FirebaseAuth firebaseAuth})
      : _firebaseAuth = firebaseAuth;

  @override
  Future<User?> register(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e, s) {
      log(
        'FirebaseAuthException',
        error: e.toString(),
        stackTrace: s,
      );
      // email-already-exists
      if (e.code == 'email-already-in-use') {
        final loginTypes =
            await _firebaseAuth.fetchSignInMethodsForEmail(email);
        if (loginTypes.contains('password')) {
          throw AuthException(
              message: 'E-mail já utilizado, por favor escolha outro e-mail');
        } else {
          throw AuthException(
              message:
                  'Você já se cadastrou no TodoList pelo Google. Por favor, use o Google como opção de login.');
        }
      } else {
        throw AuthException(message: e.message ?? 'Erro ao registrar usuário');
      }
    }
  }
}
