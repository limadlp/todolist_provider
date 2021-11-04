import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
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

  @override
  Future<User?> login(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on PlatformException catch (e, s) {
      log(
        'PlatformException',
        error: e.toString(),
        stackTrace: s,
      );
      throw AuthException(message: e.message ?? 'Erro ao realizar login');
    } on FirebaseAuthException catch (e, s) {
      log(
        'FirebaseAuthException',
        error: e.toString(),
        stackTrace: s,
      );
      if (e.code == 'wrong-password') {
        throw AuthException(message: 'Login ou senha inválidos');
      }
      throw AuthException(message: e.message ?? 'Erro ao realizar login');
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      final loginMethods = await _firebaseAuth.fetchSignInMethodsForEmail(
        email,
      );
      if (loginMethods.contains('password')) {
        await _firebaseAuth.sendPasswordResetEmail(
          email: email,
        );
      } else if (loginMethods.contains('google')) {
        throw AuthException(
          message:
              'Cadastro realizado com o Google, a senha não pode ser resetada',
        );
      } else {
        throw AuthException(
          message: 'E-mail não cadastrado',
        );
      }
    } on PlatformException catch (e, s) {
      log(
        'FirebaseAuthException',
        error: e.toString(),
        stackTrace: s,
      );
      throw AuthException(
        message: 'Erro ao resetar senha',
      );
    }
  }
}
