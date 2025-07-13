import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Create user with email and password
  Future<User?> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Login user with email and password
  Future<User?> loginUserWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      return userCredential.user;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Sign out from Firebase
  Future<void> signOutFromFirebase() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception("Error signing out from Google: ${e.toString()}");
    }
  }

  // Sign out from Google
  Future<void> signOutFromGoogle() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      throw Exception("Error signing out from Google: ${e.toString()}");
    }
  }

  // Combined sign-out method for both Firebase and Google
  Future<void> signOut() async {
    try {
      await signOutFromGoogle(); // Google sign-out
      await signOutFromFirebase(); // Firebase sign-out
    } catch (e) {
      throw Exception("Error during sign-out: ${e.toString()}");
    }
  }

  // Reset password
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception("Error sending password reset email: ${e.toString()}");
    }
  }

  signInWithEmailAndPassword(String email, String password) {}
}
