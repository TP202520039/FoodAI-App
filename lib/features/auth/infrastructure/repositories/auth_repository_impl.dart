import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodai/features/auth/domain/domain.dart';

class AuthRepositoryImpl extends AuthRepository {
  final AuthDatasource _authDatasource;

  AuthRepositoryImpl(this._authDatasource);

  @override
  Stream<User?> get authStateChanges => _authDatasource.authStateChanges;

  @override
  User? get currentUser => _authDatasource.currentUser;

  @override
  Future<User> signInWithEmailPassword(String email, String password) async {
    return await _authDatasource.signInWithEmailPassword(email, password);
  }

  @override
  Future<User> signInWithGoogle() async {
    return await _authDatasource.signInWithGoogle();
  }
  
  @override
  Future<void> signOut() async {
    return await _authDatasource.signOut();
  }
  
  @override
  Future<User> registerWithEmailPassword(String email, String password) async {
    return await _authDatasource.registerWithEmailPassword(email, password);
  }
}