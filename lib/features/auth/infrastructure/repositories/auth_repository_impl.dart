import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodai/features/auth/domain/domain.dart';

class AuthRepositoryImpl extends AuthRepository {
  final AuthDatasource _authDatasource;

  AuthRepositoryImpl(this._authDatasource);

  @override
  Future<UserCredential> signInWithEmailPassword(String email, String password) async {
    return await _authDatasource.signInWithEmailPassword(email, password);
  }

  @override
  Future<UserCredential> signInWithGoogle() async {
    return await _authDatasource.signInWithGoogle();
  }
  
  @override
  Future<void> signOut() async {
    return await _authDatasource.signOut();
  }
}