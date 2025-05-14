import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:go_router/go_router.dart';
import 'package:white_label_community_app/core/config/app_config.dart';

final functions = FirebaseFunctions.instance;

class StripeService {
  // Get app scheme for deep linking
  static String get appScheme => AppConfig.appScheme;

  // Create a URL that will be used by the server to redirect back to the app
  static String createSuccessDeepLink(String eventId, String sessionId) {
    return AppConfig.deepLinkConfig.getPaymentSuccessLink(eventId, sessionId);
  }

  // Create a URL for cancel redirect
  static String createCancelDeepLink(String eventId) {
    return AppConfig.deepLinkConfig.getPaymentCancelLink(eventId);
  }

  // Create a checkout session with proper redirects
  static Future<String> createStripeCheckoutSession({
    required String eventId,
    required String title,
    required double amount,
    required BuildContext context,
  }) async {
    try {
      // Convert to cents for Stripe
      final amountInCents = (amount * 100).toInt();

      // Create URLs for success and cancel
      final successUrl = createSuccessDeepLink(eventId, 'SESSION_ID');
      final cancelUrl = createCancelDeepLink(eventId);

      // Call Firebase function
      final callable = functions.httpsCallable('createCheckoutSession');
      final response = await callable.call({
        'eventId': eventId,
        'eventTitle': title,
        'amount': amountInCents,
        'successUrl': successUrl,
        'cancelUrl': cancelUrl,
        // Send the domain for verification on the server side
        'appDomain': AppConfig.deepLinkConfig.domain,
      });

      if (response.data['sessionUrl'] == null) {
        throw Exception('Failed to create checkout session');
      }

      return response.data['sessionUrl'];
    } catch (e) {
      rethrow;
    }
  }

  // This method is now deprecated and will be handled by DeepLinkHandler
  // Kept for backward compatibility
  static void handlePaymentRedirect(BuildContext context, Uri uri) {
    final path = uri.path;
    final queryParams = uri.queryParameters;

    final isSuccess = path.contains('payment-success');
    final isCancel = path.contains('payment-cancel');
    final eventId = queryParams['eventId'];
    final sessionId = queryParams['sessionId'];

    if (eventId != null && (isSuccess || isCancel)) {
      GoRouter.of(context).go(
        '/payment-result',
        extra: {
          'eventId': eventId,
          'isSuccess': isSuccess,
          'sessionId': sessionId,
        },
      );
    }
  }
}

// Updated method to use from event_detail_screen.dart
Future<void> launchStripeCheckout({
  required String eventId,
  required String title,
  required double amount,
  required BuildContext context,
}) async {
  try {
    final sessionUrl = await StripeService.createStripeCheckoutSession(
      eventId: eventId,
      title: title,
      amount: amount,
      context: context,
    );

    if (context.mounted) {
      await launchUrlString(sessionUrl, mode: LaunchMode.externalApplication);
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
