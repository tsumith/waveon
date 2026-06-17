import 'package:waveon/app_shell.dart';
import 'package:waveon/auth/logic/auth_provider.dart';
import 'package:waveon/auth/login_view.dart';
import 'package:waveon/auth/register_view.dart';
import 'package:waveon/home/views/home_view.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/players/full_player.dart';

GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: authProvider,
    redirect: (context, state) {
      final loggedIn = authProvider.isLoggedIn;
      final isGoingToAuth =
          state.fullPath == '/login' || state.fullPath == '/register';

      if (!loggedIn && !isGoingToAuth) {
        return '/login';
      } else if (loggedIn && isGoingToAuth) {
        return '/root';
      }

      return null;
    },
    routes: [
    
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      GoRoute(path: '/home', builder: (context, state) => const HomeView()),
      GoRoute(path: '/root', builder: (context, state) => const AppShell()),

      GoRoute(
        path: '/player',
        builder: (context, state) => const FullPlayerView(),
      ),
    ],
  );
}
