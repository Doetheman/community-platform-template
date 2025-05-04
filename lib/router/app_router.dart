import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:white_label_community_app/core/helper/go_router_refresh_notifier.dart';
import 'package:white_label_community_app/features/auth/state/auth_provider.dart';
import 'package:white_label_community_app/features/auth/ui/auth_screen.dart';
import 'package:white_label_community_app/features/feed/ui/create_post_screen.dart';
import 'package:white_label_community_app/features/feed/ui/feed_screen.dart';
import 'package:white_label_community_app/features/events/ui/event_list_screen.dart';
import 'package:white_label_community_app/features/events/ui/create_event_screen.dart';
import 'package:white_label_community_app/features/profile/ui/edit_profile_screen.dart';
import 'package:white_label_community_app/features/profile/ui/profile_screen.dart';
import 'package:white_label_community_app/router/bottom_nav_shell.dart';
import 'package:white_label_community_app/router/ui/settings_screen.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final appRouter = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshNotifier(authState),
    redirect: (context, state) {
      final isAuth = authState.asData?.value != null;
      final isOnAuth = state.path == '/auth';

      if (authState.isLoading) return null;

      if (!isAuth && !isOnAuth) return '/auth';
      if (isAuth && isOnAuth) return '/';
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) => BottomNavShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const EventListScreen(),
          ),
          GoRoute(
            path: '/feed',
            builder: (context, state) => const FeedScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/create-event',
        builder: (context, state) => const CreateEventScreen(),
      ),
      GoRoute(
        path: '/create-post',
        builder: (context, state) => const CreatePostScreen(),
      ),
      GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
    ],
  );
});
