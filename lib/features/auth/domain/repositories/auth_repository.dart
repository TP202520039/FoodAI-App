import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  // Stream para escuchar cambios en el estado de autenticación
  Stream<User?> get authStateChanges;
  
  // Usuario actual
  User? get currentUser;
  
  // Métodos de autenticación
  Future<User> signInWithEmailPassword(String email, String password);
  Future<User> signInWithGoogle();
  Future<User> registerWithEmailPassword(String email, String password);
  Future<void> signOut();
}