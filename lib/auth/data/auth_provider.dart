import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:waveon/auth/logic/auth_service.dart';
import 'package:waveon/models/user_model.dart';
import 'package:waveon/session/session_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../home/library/player_provider.dart';

class AuthProvider extends ChangeNotifier {
  final _auth = AuthService.instance;
  User? _user;

  Map<String, dynamic>? _userProfile;
  bool _isLoadingProfile = true;

  User? get user => _user;
  bool get isLoggedIn => _user != null;

  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isLoadingProfile => _isLoadingProfile;

  AuthProvider() {
    _auth.authStateChanges.listen((User? user) async {
      _user = user;
      if (user != null) {
        await refreshProfile();
      } else {
        _userProfile = null;
        _isLoadingProfile = false;
      }
      notifyListeners();
    });
  }

  Future<void> refreshProfile() async {
    _isLoadingProfile = true;
    notifyListeners();
    _userProfile = await _auth.getUserProfile();
    _isLoadingProfile = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email, password);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> register(String email, String password, String username) async {
    await _auth.registerWithEmailAndPassword(
      email: email,
      password: password,
      username: username,
    );
  }

  void logout(BuildContext context) async {
    Provider.of<PlayerProvider>(context, listen: false).stopAndClear();
    Provider.of<SessionProvider>(context, listen: false).stopSession();
  }
}
