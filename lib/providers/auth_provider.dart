import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_profile.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User?        _firebaseUser;
  UserProfile? _userProfile;
  bool         _isLoading = false;
  String?      _errorMessage;

  User?        get firebaseUser  => _firebaseUser;
  UserProfile? get userProfile   => _userProfile;
  bool         get isLoading     => _isLoading;
  String?      get errorMessage  => _errorMessage;
  bool         get isLoggedIn    => _firebaseUser != null;

  AuthProvider() {
    // Listen to firebase auth changes
    _authService.authStateChanges.listen(_onAuthChanged);
  }

  void _onAuthChanged(User? user) async {
    _firebaseUser = user;
    if (user != null) {
      // Load the user profile from Firestore
      _userProfile = await _authService.fetchUserProfile(user.uid);
    } else {
      _userProfile = null;
    }
    notifyListeners();
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Sign Up

  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    final error = await _authService.signUp(
      email:       email,
      password:    password,
      displayName: displayName,
    );

    _setLoading(false);

    if (error != null) {
      _errorMessage = error;
      notifyListeners();
      return false;
    }
    return true;
  }

  // Sign In

  Future<bool> signIn({required String email, required String password}) async {
    _setLoading(true);
    _errorMessage = null;

    final error = await _authService.signIn(email: email, password: password);

    _setLoading(false);

    if (error != null) {
      _errorMessage = error;
      notifyListeners();
      return false;
    }
    return true;
  }

  // Sign Out
  Future<void> signOut() async {
    await _authService.signOut();
  }

  // Notification Toggle
  Future<void> toggleNotifications(bool enabled) async {
    if (_firebaseUser == null || _userProfile == null) return;

    await _authService.updateNotificationPref(_firebaseUser!.uid, enabled);
    _userProfile = _userProfile!.copyWith(notificationsEnabled: enabled);
    notifyListeners();
  }

  //Resend Verification 

  Future<String?> resendVerification() {
    return _authService.resendVerification();
  }
}
