import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
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

  Future<User?> signInWithGoogle({bool forceAccountSelection = true}) async {
    try {
      if (forceAccountSelection) {
        await _googleSignIn.signOut(); // forces account picker
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // user cancelled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Check if already signed up (useful only in Signin screen)
      final signInMethods =
          await _auth.fetchSignInMethodsForEmail(googleUser.email);

      // If no method, it’s new user. If method exists, it’s existing.
      // Let the caller decide what to do.

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      throw Exception("Google Sign-In failed: ${e.toString()}");
    }
  }

  // Sign out from Firebase
  Future<void> signOutFromFirebase() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception("Error signing out from Firebase: ${e.toString()}");
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
}
