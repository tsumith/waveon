import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth/data/auth_provider.dart';
import 'auth/data/username_provider.dart';
import 'home/library/lib_provider.dart';
import 'home/library/player_provider.dart';
import 'network/socket_service.dart';
import 'session/session_provider.dart';

class AppProviders extends StatelessWidget {
  const AppProviders({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<UsernameProvider>(create: (_) => UsernameProvider()),
        ChangeNotifierProvider<LibProvider>(create: (_) => LibProvider()),
        ChangeNotifierProvider<PlayerProvider>(create: (_) => PlayerProvider()),
        ChangeNotifierProvider<SessionProvider>(
          create: (_) => SessionProvider(SocketService.instance),
        ),
      ],
      child: child,
    );
  }
}