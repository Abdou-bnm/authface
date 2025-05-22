import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../core/constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔐 Sign Up with Email & Password
  Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String registrationNumber,
  }) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) throw Exception("User creation failed.");

      // Send email verification
      await user.sendEmailVerification();

      // Save additional user info to Firestore
      await _firestore.collection(Constants.usersCollection).doc(user.uid).set({
        'first_name': firstName,
        'last_name': lastName,
        'registration_number': registrationNumber,
        'email': email,
        'created_at': FieldValue.serverTimestamp(),
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception('This email is already in use.');
      }
      throw Exception(e.message ?? 'Signup failed.');
    }
  }

  // 🔑 Login with Email & Password
  Future<void> login({required String email, required String password}) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!credential.user!.emailVerified) {
        await _auth.signOut();
        throw Exception('Email not verified. Please check your inbox.');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No user found for this email.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Incorrect password.');
      }
      throw Exception(e.message ?? 'Login failed.');
    }
  }

  // 🔁 Forgot Password
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Could not send password reset email.');
    }
  }

  // 🔓 Google Sign-In
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) throw Exception('Google Sign-In canceled.');

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) throw Exception("Google Sign-In failed.");

      // Save user if it's a new user
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        await _firestore.collection(Constants.usersCollection).doc(user.uid).set({
          'first_name': user.displayName?.split(' ').first ?? '',
          'last_name': user.displayName?.split(' ').skip(1).join(' ') ?? '',
          'email': user.email,
          'created_at': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Google Sign-In error: ${e.toString()}');
    }
  }

  // 🚪 Logout
  Future<void> logout() async {
    await _auth.signOut();
    await GoogleSignIn().signOut(); // also logout Google if used
  }

  // 🔍 Check if user is logged in
  User? get currentUser => _auth.currentUser;

  // 📧 Check email verification
  Future<bool> isEmailVerified() async {
    final user = _auth.currentUser;
    await user?.reload(); // refresh state
    return user?.emailVerified ?? false;
  }
}
