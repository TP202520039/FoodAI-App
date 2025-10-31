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
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;


    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken,
    );

    return await _firebaseAuth.signInWithCredential(credential);
  }
  
  @override
  Future<void> signOut() async{
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }
}