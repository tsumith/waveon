import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:waveon/core/services/permission_service.dart';

class WifiPermissionDialog extends StatelessWidget {
  const WifiPermissionDialog({super.key});

  static Future<bool> requestAndCheck(BuildContext context) async {
    final currentStatus = await Permission.nearbyWifiDevices.status;
    if (currentStatus.isGranted) return true;

    final isBlocked = await PermissionService.instance
        .isNearbyWifiPermanentlyDenied();

    if (isBlocked) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "Nearby devices blocked. Enable in settings.",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF1A1A1A),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'SETTINGS',
              textColor: Colors.blueAccent,
              onPressed: () {
                openAppSettings();
              },
            ),
          ),
        );
      }
      return false;
    }
    final agreed =
        await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => const WifiPermissionDialog(),
        ) ??
        false;
    if (!agreed) return false;
    final status = await PermissionService.instance.requestNearbyDevices();
    return status.isGranted;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.wifi_tethering_rounded,
              color: Colors.blueAccent,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            "Nearby Devices",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
      content: const Text(
        "WaveOn needs permission to find nearby devices on your Wi-Fi network.\n\nThis allows the app to connect with other listeners and sync music playback in real time. No data leaves your local network.",
        style: TextStyle(color: Colors.white70, height: 1.6, fontSize: 14),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context, false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white54,
                  side: BorderSide(color: Colors.white.withOpacity(0.15)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text("Not Now"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  "Continue",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
