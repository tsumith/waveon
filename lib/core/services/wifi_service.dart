import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:network_info_plus/network_info_plus.dart';

class WifiService {
  WifiService._internal();
  static final WifiService instance = WifiService._internal();
  final NetworkInfo _netInfo = NetworkInfo();

  /// Returns current device IP
  Future<String?> getWifiIP() async {
    try {
      String? ip = await _netInfo.getWifiIP();
      if (ip != null && ip != "0.0.0.0") return ip;

      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
      );

      for (var interface in interfaces) {
        for (var address in interface.addresses) {
          // Ignore localhost (127.0.0.1)
          if (!address.isLoopback) {
            return address.address;
          }
        }
      }
    } catch (e) {
      debugPrint("Error finding IP: $e");
    }
    return null;
  }

  ///  Returns gateway host ip
  Future<String?> getWifiGatewayIP() async {
    try {
      return await _netInfo.getWifiGatewayIP();
    } catch (e) {
      debugPrint("Error finding Gateway IP: $e");
      return null;
    }
  }

  /// Returns connection Status
  Future<bool> isConnectedToWifi() async {
    try {
      final ip = await _netInfo.getWifiIP();
      return ip != null;
    } catch (e) {
      debugPrint("Error checking connection status: $e");
      return false;
    }
  }
}
