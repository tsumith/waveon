import 'package:flutter/foundation.dart';

class AuthService {
  static final AuthService instance = AuthService._internal();
  AuthService._internal();

  User? getCurrentUser() {
    return null;
  }

  Stream<User?> get authStateChanges {
    return const Stream.empty();
  }

  String? getEmail() {
    return null;
  }

  Future<bool?> isUsernameUnique(String username) async {
    return null;
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    return null;
  }

  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    throw UnimplementedError(
      "Auth implementation abstracted for public showcase.",
    );
  }

  Future<void> registerWithEmailAndPassword({
    required String username,
    required String email,
    required String password,
  }) async {}

  Future<void> changeUsername(String newUsername) async {}

  Future<void> deleteAccount() async {}

  Future<void> signOut() async {}

  Future<void> sendPasswordResetEmail(String email) async {}
}
