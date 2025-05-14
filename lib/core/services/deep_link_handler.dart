import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:uni_links/uni_links.dart';
import 'package:white_label_community_app/core/config/app_config.dart';

/// A service for handling deep links in the application
/// This uses the uni_links package for handling universal links and app links
/// without relying on Firebase Dynamic Links
class DeepLinkHandler {
  static bool _isInitialized = false;
  static StreamSubscription? _linkSubscription;

  /// Initialize the deep link handler to capture incoming links
  static Future<void> initialize(BuildContext context) async {
    if (_isInitialized) return;

    // Handle links when app is started from a link
    try {
      final initialLink = await getInitialUri();
      if (initialLink != null) {
        if (context.mounted) {
          _handleIncomingUri(initialLink, context);
        }
      }
    } on PlatformException {
      // Ignore platform exceptions
    }

    // Handle links while app is running
    _linkSubscription = uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null) {
          _handleIncomingUri(uri, context);
        }
      },
      onError: (error) {
        debugPrint('Deep link error: $error');
      },
    );

    _isInitialized = true;
  }

  /// Cleanup resources
  static void dispose() {
    _linkSubscription?.cancel();
    _isInitialized = false;
  }

  /// Process an incoming URI
  static void _handleIncomingUri(Uri uri, BuildContext context) {
    final host = uri.host;
    final path = uri.path;

    // Check if this is a payment-related link using our configured domain
    if (host == AppConfig.deepLinkConfig.domain) {
      if (path.contains('/payment-success') ||
          path.contains('/payment-cancel')) {
        _handlePaymentRedirect(uri, context);
      } else {
        // Handle other types of deep links
        _handleGeneralDeepLink(uri, context);
      }
    } else {
      // Handle links from other domains
      _handleGeneralDeepLink(uri, context);
    }
  }

  /// Handle payment redirect URLs from Stripe
  static void _handlePaymentRedirect(Uri uri, BuildContext context) {
    final path = uri.path;
    final params = uri.queryParameters;
    final eventId = params['eventId'];

    if (eventId == null) {
      // If no event ID, just go to home
      GoRouter.of(context).go('/');
      return;
    }

    if (path.contains('/payment-success')) {
      final sessionId = params['sessionId'];
      final status = params['status'] ?? 'success';

      // First show payment result screen
      GoRouter.of(context).go(
        '/payment-result',
        extra: {
          'eventId': eventId,
          'isSuccess': status == 'success',
          'sessionId': sessionId,
        },
      );

      // Schedule navigation back to event page after showing result
      Future.delayed(const Duration(seconds: 3), () {
        if (context.mounted) {
          GoRouter.of(context).go('/event/$eventId');
        }
      });
    } else if (path.contains('/payment-cancel')) {
      // For cancel, we can either:
      // Option 1: Show payment result screen with failure
      GoRouter.of(
        context,
      ).go('/payment-result', extra: {'eventId': eventId, 'isSuccess': false});

      // Schedule navigation back to event page after showing result
      Future.delayed(const Duration(seconds: 2), () {
        if (context.mounted) {
          GoRouter.of(context).go('/event/$eventId');
        }
      });

      // Option 2: Go directly back to event page
      // GoRouter.of(context).go('/event/$eventId');
    }
  }

  /// Handle other types of deep links
  static void _handleGeneralDeepLink(Uri uri, BuildContext context) {
    final router = GoRouter.of(context);
    // Add handling for other types of deep links here
    final path = uri.path;
    final params = uri.queryParameters;

    if (path.startsWith('/event/')) {
      final eventId = params['id'] ?? uri.pathSegments.last;
      // Navigate to event screen
      router.push('/event/$eventId');
    } else if (path.startsWith('/profile')) {
      // Navigate to profile screen
      router.push('/profile');
    } else if (path.startsWith('/notifications')) {
      // Navigate to notifications screen
      router.push('/notifications');
    } else {
      // Default to home screen
      router.push('/');
    }
  }
}
