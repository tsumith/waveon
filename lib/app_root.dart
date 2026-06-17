import 'package:flutter/material.dart';
import 'package:waveon/auth/logic/auth_provider.dart';
import 'package:waveon/core/nav/main_router.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  late GoRouter router;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    router = createRouter(authProvider);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0D0D),
        canvasColor: const Color(0xFF0D0D0D),
      ),
      routerConfig: router,
    );
  }
}
