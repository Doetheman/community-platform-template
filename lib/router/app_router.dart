import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:white_label_community_app/core/helper/go_router_refresh_notifier.dart';
import 'package:white_label_community_app/features/auth/state/auth_provider.dart';
import 'package:white_label_community_app/features/auth/ui/auth_screen.dart';
import 'package:white_label_community_app/features/events/domain/entities/event.dart';
import 'package:white_label_community_app/features/events/ui/edit_event_screen.dart';
import 'package:white_label_community_app/features/events/ui/event_detail_screen.dart';
import 'package:white_label_community_app/features/events/ui/events_screen.dart';
import 'package:white_label_community_app/features/events/ui/payment_result_screen.dart';
import 'package:white_label_community_app/features/feed/ui/create_post_screen.dart';
import 'package:white_label_community_app/features/feed/ui/feed_screen.dart';
import 'package:white_label_community_app/features/events/ui/create_event_screen.dart';
import 'package:white_label_community_app/features/media/ui/screens/album_detail_screen.dart';
import 'package:white_label_community_app/features/media/ui/screens/albums_screen.dart';
import 'package:white_label_community_app/features/media/ui/screens/media_detail_screen.dart';
import 'package:white_label_community_app/features/media/ui/screens/media_gallery_screen.dart';
import 'package:white_label_community_app/features/profile/ui/edit_profile_screen.dart';
import 'package:white_label_community_app/features/profile/ui/profile_screen.dart';
import 'package:white_label_community_app/features/profile/ui/view_profile_screen.dart';
import 'package:white_label_community_app/router/bottom_nav_shell.dart';
import 'package:white_label_community_app/router/ui/settings_screen.dart';
import 'package:white_label_community_app/features/community/ui/screens/messages_screen.dart';

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
      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) => BottomNavShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const EventsScreen()),
          GoRoute(
            path: '/feed',
            builder: (context, state) => const FeedScreen(),
          ),
          GoRoute(
            path: '/messages',
            builder: (context, state) => const MessagesScreen(),
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
      GoRoute(
        path: '/edit-event/:eventId',
        builder: (context, state) {
          final event = state.extra as Event;
          return EditEventScreen(event: event);
        },
      ),
      GoRoute(
        path: '/event/:eventId',
        builder: (context, state) {
          final event = state.extra as Event;

          return EventDetailScreen(event: event);
        },
      ),
      GoRoute(
        path: '/profile/:uid',
        builder: (context, state) {
          final uid = state.extra as String;
          return ViewProfileScreen(uid: uid);
        },
      ),
      GoRoute(
        path: '/payment-result',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          final eventId = extra['eventId'] as String;
          final isSuccess = extra['isSuccess'] as bool;
          final sessionId = extra['sessionId'] as String?;

          return PaymentResultScreen(
            eventId: eventId,
            isSuccess: isSuccess,
            sessionId: sessionId,
          );
        },
      ),
      // Media Routes
      GoRoute(
        path: '/media-gallery/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId'] ?? '';
          final isCurrentUser =
              state.uri.queryParameters['isCurrentUser'] == 'true';
          return MediaGalleryScreen(
            userId: userId,
            isCurrentUser: isCurrentUser,
          );
        },
      ),
      GoRoute(
        path: '/media/:mediaId',
        builder: (context, state) {
          final mediaId = state.pathParameters['mediaId'] ?? '';
          return MediaDetailScreen(mediaId: mediaId);
        },
      ),
      GoRoute(
        path: '/albums/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId'] ?? '';
          final isCurrentUser =
              state.uri.queryParameters['isCurrentUser'] == 'true';
          return AlbumsScreen(userId: userId, isCurrentUser: isCurrentUser);
        },
      ),
      GoRoute(
        path: '/albums/detail/:albumId',
        builder: (context, state) {
          final albumId = state.pathParameters['albumId'] ?? '';
          return AlbumDetailScreen(albumId: albumId);
        },
      ),
    ],
  );
});
