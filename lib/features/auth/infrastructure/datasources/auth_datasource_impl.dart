import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodai/features/auth/domain/datasources/auth_datasource.dart';
import 'package:foodai/features/auth/domain/entities/auth_exceptions.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthDatasourceImpl extends AuthDatasource {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthDatasourceImpl();

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  @override
  Future<User> signInWithEmailPassword(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user == null) {
        throw UnknownAuthException('No se pudo obtener la información del usuario');
      }
      
      return userCredential.user!;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw UserNotFoundException();
        case 'wrong-password':
          throw WrongPasswordException();
        case 'invalid-email':
          throw InvalidEmailException();
        case 'user-disabled':
          throw AuthException('Esta cuenta ha sido deshabilitada');
        case 'network-request-failed':
          throw NetworkException();
        default:
          throw UnknownAuthException(e.message);
      }
    } catch (e) {
      throw UnknownAuthException('Error inesperado: $e');
    }
  }

  @override
  Future<User> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      // Si el usuario cancela el popup
      if (googleUser == null) {
        throw GoogleSignInCancelledException();
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      
      if (userCredential.user == null) {
        throw UnknownAuthException('No se pudo obtener la información del usuario');
      }
      
      return userCredential.user!;
    } on GoogleSignInCancelledException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'account-exists-with-different-credential':
          throw AuthException('Ya existe una cuenta con este correo usando otro método de inicio de sesión');
        case 'invalid-credential':
          throw AuthException('Las credenciales de Google son inválidas');
        case 'network-request-failed':
          throw NetworkException();
        default:
          throw UnknownAuthException(e.message);
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw UnknownAuthException('Error en Google Sign-In: $e');
    }
  }
  
  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
        // Removido disconnect() para permitir cambio de cuenta sin desconectar completamente
      ]);
    } catch (e) {
      throw UnknownAuthException('Error al cerrar sesión: $e');
    }
  }
}