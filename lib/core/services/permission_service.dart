import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class PermissionService {
  static final PermissionService instance = PermissionService._internal();
  PermissionService._internal();

  Future<bool> requestLibraryPermission() async {
    if (!Platform.isAndroid) return true;

    final plugin = DeviceInfoPlugin();
    final androidInfo = await plugin.androidInfo;

    final Permission targetPermission =
        androidInfo.version.sdkInt >= 33
            ? Permission.audio
            : Permission.storage;

    PermissionStatus status = await targetPermission.status;
    if (status.isGranted) {
      return true;
    }
    status = await targetPermission.request();
    if (status.isPermanentlyDenied) {
      openAppSettings();
    }
    return status.isGranted;
  }

  Future<bool> checkLibraryPermission() async {
    if (!Platform.isAndroid) return true;

    final plugin = DeviceInfoPlugin();
    final androidInfo = await plugin.androidInfo;

    final Permission targetPermission =
        androidInfo.version.sdkInt >= 33
            ? Permission.audio
            : Permission.storage;

    PermissionStatus status = await targetPermission.status;
    return status.isGranted;
  }

  Future<PermissionStatus> requestNearbyDevices() async {
    if (!Platform.isAndroid) return PermissionStatus.granted;

    final plugin = DeviceInfoPlugin();
    final androidInfo = await plugin.androidInfo;

    if (androidInfo.version.sdkInt < 33) {
      return PermissionStatus
          .granted;
    }

    final result = await Permission.nearbyWifiDevices.request();
    return result;
  }

  Future<bool> isNearbyWifiPermanentlyDenied() async {
    if (!Platform.isAndroid) return false;
    final plugin = DeviceInfoPlugin();
    final androidInfo = await plugin.androidInfo;
    if (androidInfo.version.sdkInt < 33) return false;

    return await Permission.nearbyWifiDevices.status.isPermanentlyDenied;
  }
}
