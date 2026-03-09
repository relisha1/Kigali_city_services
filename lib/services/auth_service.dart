import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get the current logged-in user
  User? get currentUser => _auth.currentUser;

  // Stream that updates whenever auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<String?> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;
      if (user == null) return 'Something went wrong. Please try again.';

      // Update display name in Firebase Auth
      await user.updateDisplayName(displayName);

      // Save user profile in Firestore
      final profile = UserProfile(
        uid:         user.uid,
        email:       email,
        displayName: displayName,
        createdAt:   DateTime.now(),
      );
      await _db.collection('users').doc(user.uid).set(profile.toMap());

      // Send email verification
      await user.sendEmailVerification();

      return null; // null means success
    } on FirebaseAuthException catch (e) {
      return _friendlyError(e.code);
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  // Log in
  Future<String?> signIn({
    required String email,
    required String password,
}) async {
  try {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = result.user;
    if (user == null) return 'Login failed. Please try again.';

    return null;
  } on FirebaseAuthException catch (e) {
    return _friendlyError(e.code);
  } catch (e) {
    return 'Error: $e';
  }
}

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Resend verification email
  Future<String?> resendVerification() async {
    try {
      await currentUser?.sendEmailVerification();
      return null;
    } catch (e) {
      return 'Failed to send email. Please try again later.';
    }
  }

  // Fetch user profile from Firestore
  Future<UserProfile?> fetchUserProfile(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) return UserProfile.fromDoc(doc);
      return null;
    } catch (e) {
      return null;
    }
  }

  // Update notification preference
  Future<void> updateNotificationPref(String uid, bool enabled) async {
    await _db.collection('users').doc(uid).update({
      'notificationsEnabled': enabled,
    });
  }

  // Convert Firebase error codes into plain english
  String _friendlyError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered. Try logging in.';
      case 'invalid-email':
        return 'That email address doesn\'t look right.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'user-not-found':
        return 'No account found with that email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return 'Something went wrong ($code). Please try again.';
    }
  }
}
