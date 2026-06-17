import 'dart:async';

import 'package:flutter/material.dart';
import 'package:waveon/core/services/wifi_service.dart';
import 'package:waveon/core/enums.dart';
import 'package:waveon/network/media_server.dart';
import 'package:waveon/network/session_manager.dart';
import 'package:waveon/network/socket_service.dart';
import '../models/user_model.dart';

class SessionProvider extends ChangeNotifier {
  final SocketService _socketService;
  final MediaServer _mediaServer = MediaServer.instance;
  final SessionManager _sessionManager = SessionManager.instance;
  final UserModel _currentUser = UserModel.instance;

  UserRole get role => _currentUser.role;
  int get connectedNodes => _socketService.connectedGuestCount;

  final _toastController = StreamController<String>.broadcast();
  Stream<String> get toastStream => _toastController.stream;

  SessionProvider(this._socketService) {
    _socketService.onConnectionDropped = () {
      debugPrint(
        "Session provider : fatal network drop detected. Cleaning up ui state..",
      );
      stopSession();
    };

    _socketService.onGuestCountChanged = () {
      notifyListeners();
    };

    _socketService.onSystemMessage = (message) {
      _toastController.add(message);
    };
  }

  Future<bool> createRoom() async {
    if (role == UserRole.guest) return false;
    try {
      await _socketService.startHosting();
      final port = await _mediaServer.startServer();
      if (port == -1) {
        throw Exception("Port 8080 is blocked or already in use.");
      }
      _currentUser.role = UserRole.host;
      _sessionManager.initializeSession();
      _toastController.add("Host session started successfully.");
      notifyListeners();
      return true;
    } catch (e) {
      _toastController.add("Failed to host: Failed to bind port.");
      debugPrint("HOST EXCEPTION: ${e.toString()}");
      stopSession();
      return false;
    }
  }

  Future<bool> joinRoom() async {
    if (role == UserRole.host) return false;
    final ipAddress = await WifiService.instance.getWifiGatewayIP();
    if (ipAddress == null) {
      _toastController.add("Cannot find Host IP. Check your WiFi.");
      return false;
    }
    try {
      await _socketService.connectToHost(ipAddress);
      _currentUser.role = UserRole.guest;
      _sessionManager.initializeSession();
      _toastController.add("Connected to Host!");
      notifyListeners();
      return true;
    } on TimeoutException {
      _toastController.add("Connection timed out. Is the host running?");
      stopSession();
      return false;
    } catch (e) {
      _toastController.add("Failed to connect: Network error.");
      stopSession();
      return false;
    }
  }

  void stopSession() {
    if (_currentUser.role == UserRole.none) return;
    _currentUser.role = UserRole.none;
    try {
      _socketService.closeConnections();
    } catch (e) {
      debugPrint("Error closing sockets: $e");
    }
    try {
      _mediaServer.stopServer();
    } catch (e) {
      debugPrint("Error stopping media server: $e");
    }
    try {
      _sessionManager.disposeSession();
    } catch (e) {
      debugPrint("Error disposing session manager: $e");
    }
    _toastController.add("Session disconnected.");
    notifyListeners();
  }
}
