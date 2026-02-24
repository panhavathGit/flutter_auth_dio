import 'package:auth_dio/features/todo/todo.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/auth.dart';
import '../../features/profile/presentation/views/profile_page.dart';
import './app_routes.dart';
import '../services/storage_service.dart';

class AppRouter {
  final StorageService storageService;

  AppRouter(this.storageService);

  // static const bool _bypassAuth = true;

  late final GoRouter router = GoRouter(
    debugLogDiagnostics: true,

    initialLocation: AppPaths.login,

    // ─── Auth guard ───────────────────────────────
    redirect: (BuildContext context, GoRouterState state) async {

      // if(_bypassAuth) return null;

      final isLoggedIn = await storageService.isLoggedIn();

      final isGoingToLogin    = state.matchedLocation == AppPaths.login;
      final isGoingToRegister = state.matchedLocation == AppPaths.register;

      // not logged in → force to login
      if (!isLoggedIn && !isGoingToLogin && !isGoingToRegister) {
        return AppPaths.login;
      }

      // already logged in → skip auth pages
      if (isLoggedIn && (isGoingToLogin || isGoingToRegister)) {
        return AppPaths.main;
      }

      return null; // no redirect
    },

    routes: [
      // ─── Auth Routes ──────────────────────────
      GoRoute(
        path: AppPaths.login,
        name: AppRoutes.login,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: LoginScreen(),
        ),
      ),
      GoRoute(
        path: AppPaths.register,
        name: AppRoutes.register,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: RegisterScreen(),
        ),
      ),

      // ─── Main App with Bottom Nav ─────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          // Todo Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppPaths.main,
                name: AppRoutes.main,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: TodoListScreen(),
                ),
              ),
            ],
          ),

          // Profile Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppPaths.profile,
                name: AppRoutes.profile,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ProfilePage(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],

    // ─── Error page ───────────────────────────
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            Text('Page not found',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('${state.uri}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.goNamed(AppRoutes.main),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}

// ─── Bottom Nav Scaffold ──────────────────────────
class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        selectedItemColor: const Color(0xFF053CC7),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}