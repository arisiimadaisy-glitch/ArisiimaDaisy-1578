import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/models/user_model.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Returns current user synchronously
  User? getCurrentUser() {
    final fbUser = _auth.currentUser;
    if (fbUser == null) return null;
    return User.fromFirebaseUser(fbUser, _getProviderFromFirebaseUser(fbUser));
  }

  /// Stream of auth state changes
  Stream<User?> userStateChanges() {
    return _auth.authStateChanges().map((fbUser) {
      if (fbUser == null) return null;
      return User.fromFirebaseUser(
        fbUser,
        _getProviderFromFirebaseUser(fbUser),
      );
    });
  }

  /// Sign in with email and password
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        await _storeOrUpdateUser(result.user!, 'email');
        return User.fromFirebaseUser(result.user!, 'email');
      }
      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    }
  }

  /// Register with email and password
  Future<User?> registerWithEmail(
    String email,
    String password,
    String name,
  ) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        // Update display name
        await result.user!.updateDisplayName(name);

        // Store user in Firestore
        await _storeOrUpdateUser(result.user!, 'email', name: name);

        return User.fromFirebaseUser(
          result.user!,
          'email',
        ).copyWith(name: name.trim());
      }
      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    }
  }

  /// Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      late final firebase_auth.UserCredential result;
      if (kIsWeb) {
        result = await _auth.signInWithPopup(
          firebase_auth.GoogleAuthProvider(),
        );
      } else {
        final googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return null;

        final googleAuth = await googleUser.authentication;
        final credential = firebase_auth.GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken,
        );
        result = await _auth.signInWithCredential(credential);
      }

      if (result.user != null) {
        await _storeOrUpdateUser(result.user!, 'google');
        return User.fromFirebaseUser(result.user!, 'google');
      }
      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    } catch (e) {
      throw 'Google sign-in failed: $e';
    }
  }

  /// Sign in with GitHub
  Future<User?> signInWithGithub() async {
    try {
      final provider = firebase_auth.GithubAuthProvider();
      final result = kIsWeb
          ? await _auth.signInWithPopup(provider)
          : await _auth.signInWithProvider(provider);

      if (result.user != null) {
        await _storeOrUpdateUser(result.user!, 'github');
        return User.fromFirebaseUser(result.user!, 'github');
      }
      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'operation-not-allowed') {
        throw 'GitHub sign-in not configured. Please ensure GitHub OAuth is enabled in Firebase Console.';
      }
      throw _mapFirebaseError(e);
    } catch (e) {
      throw 'GitHub sign-in failed: $e';
    }
  }

  /// Sign out user
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  /// Convert FirebaseAuthException codes to user-friendly messages
  String _mapFirebaseError(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Email address not found. Please check or create a new account.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'This email is already registered. Please log in or use a different email.';
      case 'weak-password':
        return 'Password is too weak. Must be at least 8 characters with letters and numbers.';
      case 'network-request-failed':
        return 'Network connection failed. Please check your internet and try again.';
      case 'invalid-email':
        return 'Email format is invalid. Please enter a valid email address.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled. Please contact support.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with this email using a different sign-in method.';
      case 'invalid-credential':
        return 'Invalid credentials. Please try again.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }

  /// Store or update user in Firestore
  Future<void> _storeOrUpdateUser(
    firebase_auth.User fbUser,
    String authProvider, {
    String? name,
  }) async {
    final docRef = _firestore.collection('users').doc(fbUser.uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      await docRef.set({
        'id': fbUser.uid,
        'email': fbUser.email ?? '',
        'name': name ?? fbUser.displayName ?? '',
        'profilePictureUrl': fbUser.photoURL,
        'authProvider': authProvider,
        'currency': 'USD',
        'createdAt': DateTime.now().toIso8601String(),
        'lastLogin': DateTime.now().toIso8601String(),
      });
    } else {
      await docRef.update({'lastLogin': DateTime.now().toIso8601String()});
    }
  }

  /// Get auth provider from Firebase User
  String _getProviderFromFirebaseUser(firebase_auth.User fbUser) {
    if (fbUser.providerData.any((p) => p.providerId == 'google.com'))
      return 'google';
    if (fbUser.providerData.any((p) => p.providerId == 'github.com'))
      return 'github';
    return 'email';
  }
}
