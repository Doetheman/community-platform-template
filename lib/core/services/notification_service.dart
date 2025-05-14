import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotificationService {
  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        // Handle local notification tap
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          final data = _deserializeNotificationPayload(payload);
          // Store this data to be handled when we have a context
          _pendingNotificationData = data;
        }
      },
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      final data = message.data;
      if (notification != null) {
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: const AndroidNotificationDetails(
              'default_channel',
              'Default',
              importance: Importance.high,
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          payload: _serializeNotificationData(data),
        );
      }
    });

    // Handle notification click when app is in terminated state
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationClick(initialMessage.data['link']);
    }

    // Handle notification click when app is in background state
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationClick(message.data['link']);
    });
  }

  void _handleNotificationClick(String? payload) {
    if (payload == null || payload.isEmpty) return;

    // Convert payload string back to map
    final data = _deserializeNotificationPayload(payload);

    // Store the data for later navigation if app isn't fully initialized
    _pendingNotificationData = data;

    // Notify listeners that we have new data
    _notifyPendingNavigation();
  }

  // Storage for pending notification data
  Map<String, String>? _pendingNotificationData;
  Function(Map<String, String> data, BuildContext context)?
  _pendingNavigationCallback;

  // Method to check and handle any pending navigation when the app is ready
  void checkPendingNotificationNavigation(BuildContext context) {
    if (_pendingNotificationData != null) {
      final data = Map<String, dynamic>.from(_pendingNotificationData!);
      _navigateBasedOnMessageData(data, context);
      _pendingNotificationData = null;
    }
  }

  // Set up a callback for pending navigation
  void onPendingNavigation(
    Function(Map<String, String>, BuildContext) callback,
  ) {
    _pendingNavigationCallback = callback;
  }

  // Notify when there's pending navigation
  void _notifyPendingNavigation() {
    if (_pendingNotificationData != null &&
        _pendingNavigationCallback != null) {
      // If we have both data and a context, we can navigate now
      // This will be called once we have a valid BuildContext
    }
  }

  // Navigate based on the notification data
  void _navigateBasedOnMessageData(
    Map<String, dynamic> data,
    BuildContext context,
  ) {
    final String? route = data['route'] as String?;
    final String? screenType = data['screen_type'] as String?;
    final String? itemId = data['item_id'] as String?;

    if (route != null && route.isNotEmpty) {
      // Direct route navigation
      GoRouter.of(context).go(route);
    } else if (screenType != null) {
      switch (screenType) {
        case 'event':
          if (itemId != null) {
            GoRouter.of(context).go('/event/$itemId');
          }
          break;
        case 'payment':
          if (itemId != null) {
            final isSuccess = data['status'] == 'success';
            final sessionId = data['session_id'] as String?;
            final returnToEvent = data['return_to_event'] == 'true';

            if (returnToEvent && isSuccess) {
              // If return_to_event is true and payment was successful,
              // show payment result briefly then navigate to event
              GoRouter.of(context).go(
                '/payment-result',
                extra: {
                  'eventId': itemId,
                  'isSuccess': isSuccess,
                  'sessionId': sessionId,
                },
              );

              // Navigate to event page after a short delay
              Future.delayed(const Duration(seconds: 2), () {
                if (context.mounted) {
                  GoRouter.of(context).go('/event/$itemId');
                }
              });
            } else {
              // Otherwise just show the payment result screen
              GoRouter.of(context).go(
                '/payment-result',
                extra: {
                  'eventId': itemId,
                  'isSuccess': isSuccess,
                  'sessionId': sessionId,
                },
              );
            }
          }
          break;
        case 'notification':
          GoRouter.of(context).go('/notifications');
          break;
        case 'profile':
          GoRouter.of(context).go('/profile');
          break;
        default:
          GoRouter.of(context).go('/');
      }
    }
  }

  // Convert notification data to serialized string for payload
  String _serializeNotificationData(Map<String, dynamic> data) {
    return data.entries.map((e) => '${e.key}:${e.value}').join(',');
  }

  // Parse serialized notification data back to map
  Map<String, String> _deserializeNotificationPayload(String? payload) {
    if (payload == null || payload.isEmpty) return {};

    final map = <String, String>{};
    final pairs = payload.split(',');

    for (final pair in pairs) {
      final keyValue = pair.split(':');
      if (keyValue.length == 2) {
        map[keyValue[0]] = keyValue[1];
      }
    }

    return map;
  }

  Future<String?> getToken() async {
    return _messaging.getToken();
  }
}
