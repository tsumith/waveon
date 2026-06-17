import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waveon/core/enums.dart';
import 'package:waveon/session/session_provider.dart';
import 'package:waveon/widgets/wifi_disclosure.dart';

class HostButton extends StatelessWidget {
  const HostButton({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SessionProvider>();
    final isHost = provider.role == UserRole.host;
    final isGuest = provider.role == UserRole.guest;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isGuest ? 0.3 : 1.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 54,
        decoration: BoxDecoration(
          color: isHost
              ? const Color(0xFF00C6FF).withOpacity(0.15)
              : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isHost
                ? const Color(0xFF00C6FF).withOpacity(0.8)
                : const Color(0xFF333333),
            width: 1.5,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: isGuest
                ? null
                : () async {
                    if (isHost) {
                      provider.stopSession();
                      return;
                    }
                    final allowed = await WifiPermissionDialog.requestAndCheck(
                      context,
                    );
                    if (!allowed) return;
                    await provider.createRoom();
                  },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    isHost
                        ? Icons.stop_circle_rounded
                        : Icons.wifi_tethering_rounded,
                    key: ValueKey(isHost),
                    color: isHost ? const Color(0xFF00C6FF) : Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    isHost ? "Stop Session" : "Host",
                    key: ValueKey(isHost),
                    style: TextStyle(
                      color: isHost ? const Color(0xFF00C6FF) : Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

///  JOIN Button
class JoinButton extends StatelessWidget {
  const JoinButton({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SessionProvider>();
    final isHost = provider.role == UserRole.host;
    final isGuest = provider.role == UserRole.guest;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isHost ? 0.3 : 1.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 54,
        decoration: BoxDecoration(
          color: isGuest ? Colors.greenAccent.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isGuest
                ? Colors.greenAccent.withOpacity(0.5)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: isHost
                ? null
                : () async {
                    if (isGuest) {
                      provider.stopSession();
                      return;
                    }
                    final allowed = await WifiPermissionDialog.requestAndCheck(
                      context,
                    );
                    if (!allowed) return;
                    await provider.joinRoom();
                  },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    isGuest ? Icons.exit_to_app_rounded : Icons.wifi,
                    key: ValueKey(isGuest),
                    color: isGuest
                        ? Colors.greenAccent
                        : const Color(0xFF0D0D0D),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    isGuest ? "Leave Session" : "Join",
                    key: ValueKey(isGuest),
                    style: TextStyle(
                      color: isGuest
                          ? Colors.greenAccent
                          : const Color(0xFF0D0D0D),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
