import 'dart:async';

import 'package:flutter/material.dart';
import 'package:waveon/home/views/home_view.dart';
import 'package:waveon/home/views/lib_view.dart';
import 'package:waveon/home/views/profile_view.dart';
import 'package:waveon/session/session_provider.dart';
import 'package:waveon/widgets/players/shell_player.dart';
import 'package:provider/provider.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  final Set<int> _visitedTabs = {0};
  StreamSubscription? _toastSubscription;

  final List<Widget> _screens = [
    const HomeView(),
    const LibView(),
    const ProfileView(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sessionProvider = context.read<SessionProvider>();
      _toastSubscription = sessionProvider.toastStream.listen((message) {
        _showGlobalToast(message);
      });
    });
  }

  @override
  void dispose() {
    _toastSubscription?.cancel();
    super.dispose();
  }

  void _showGlobalToast(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: Colors.cyanAccent,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        margin: const EdgeInsets.only(bottom: 90, left: 20, right: 20),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Padding(
        padding: EdgeInsets.only(top: padding.top),
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: [
                      const HomeView(),
                      _visitedTabs.contains(1)
                          ? const LibView()
                          : const SizedBox.shrink(),
                      _visitedTabs.contains(2)
                          ? const ProfileView()
                          : const SizedBox.shrink(),
                    ],
                  ),
                ),
                ShellPlayer(),
                BottomNavigationBar(
                  backgroundColor: Colors.white.withOpacity(0.05),
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: Colors.white,
                  unselectedItemColor: Colors.white54,
                  currentIndex: _currentIndex,
                  onTap: (val) {
                    setState(() {
                      _currentIndex = val;
                      _visitedTabs.add(val);
                    });
                  },
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home_outlined),
                      activeIcon: Icon(Icons.home),
                      label: '',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.library_music_outlined),
                      activeIcon: Icon(Icons.library_music),
                      label: '',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person_outline),
                      activeIcon: Icon(Icons.person),
                      label: '',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
