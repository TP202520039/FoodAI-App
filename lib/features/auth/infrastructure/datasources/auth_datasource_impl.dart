import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodai/features/auth/domain/datasources/auth_datasource.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthDatasourceImpl extends AuthDatasource {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthDatasourceImpl();

  @override
  Future<UserCredential> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = 
        await _firebaseAuth.signInWithEmailAndPassword(
          email: email, 
          password: password
        );
        return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception('Error during sign in: ${e.message}');
    }
  }

  @override
  Future<UserCredential> signInWithGoogle() async {
  try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      // Si el usuario cancela el popup
      if (googleUser == null) {
        throw Exception('Google sign-in cancelado por el usuario');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      return await _firebaseAuth.signInWithCredential(credential);
    } catch (e) {
      throw Exception('Error en Google Sign-In: $e');
    }
  }
  
  @override
  Future<void> signOut() async{
      await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
      _googleSignIn.disconnect(), // Desconecta completamente la cuenta
    ]);
  }
}