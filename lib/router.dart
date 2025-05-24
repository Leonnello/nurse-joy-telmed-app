import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nursejoyapp/auth/provider/auth_service.dart';
import 'package:nursejoyapp/features/chat/ui/pages/chat_list_page.dart';
import 'package:nursejoyapp/features/dashboard/ui/pages/dashboard_page.dart';
import 'package:nursejoyapp/features/map/ui/pages/viewmap.dart';
import 'package:nursejoyapp/features/profile/ui/pages/profile_page.dart';
import 'package:nursejoyapp/features/profile/ui/pages/profile_setup.dart';
import 'package:nursejoyapp/features/Settings/ui/pages/settings.dart';
import 'package:nursejoyapp/features/signing/ui/pages/loading_page.dart';
import 'package:nursejoyapp/features/signing/ui/pages/register_page.dart';
import 'package:nursejoyapp/features/signing/ui/pages/securitycheck_page.dart';
import 'package:nursejoyapp/features/signing/ui/pages/signin_page.dart';
import 'package:nursejoyapp/main.dart';
import 'package:flutter/foundation.dart';

class AppRouter {
  final AuthService authService;

  AppRouter(this.authService);

  late final GoRouter router = GoRouter(
    refreshListenable: GoRouterRefreshStream(authService),
    debugLogDiagnostics: kDebugMode,
    redirect: (context, state) async {
      final isLoggedIn = authService.user != null;
      final isLoggingIn = state.uri.path == '/signin' ||
          state.uri.path == '/register' ||
          state.uri.path == '/';

      // If not logged in and not on a login page, redirect to signin
      if (!isLoggedIn && !isLoggingIn) {
        return '/signin';
      }

      // If logged in and on a login page, redirect to home
      if (isLoggedIn && isLoggingIn) {
        // Check if user setup is completed
        final isSetup = await authService.isUserSetup();
        if (!isSetup) {
          return '/profile-setup';
        }
        return '/home';
      }

      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: '/signin',
        builder: (context, state) => const SigninPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/securitycheck',
        builder: (context, state) => const SecuritycheckPage(),
      ),

      // Main application routes
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/profile-setup',
        builder: (context, state) => const ProfileSetup(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const Settings(),
      ),
      GoRoute(
        path: '/viewmap',
        builder: (context, state) => const ViewMapPage(),
      ),

      // Individual feature routes
      GoRoute(
        path: '/profile/:userId',
        builder: (context, state) {
          final userId =
              state.pathParameters['userId'] ?? authService.user!.uid;
          return ProfilePage(userID: userId);
        },
      ),
    ],
  );
}

// Helper class to convert authService to a listenable for GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(AuthService authService) {
    authService.addListener(notifyListeners);
  }
}
