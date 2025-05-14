import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:white_label_community_app/core/services/notification_service.dart';
import 'package:white_label_community_app/core/services/deep_link_handler.dart';
import 'package:white_label_community_app/core/theme/brand_theme.dart';
import 'package:white_label_community_app/core/config/app_config.dart';
import 'router/app_router.dart';
import 'firebase_options.dart';

// Create a global provider for the notification service
final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(),
);

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background message
  print('BG message: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables first
  try {
    await dotenv.load(fileName: '.env');
    debugPrint('Environment loaded from .env file');
  } catch (e) {
    debugPrint('No .env file found or error loading it: $e');
    // Initialize with empty environment to prevent errors
    dotenv.load(fileName: '.env.example');
  }

  // Initialize app configuration with environment-specific values
  await AppConfig.loadFromEnv();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Set up environment-specific configurations
  if (AppConfig.isDevelopment) {
    FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
  }

  // Set up Firebase Messaging
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.init();

  runApp(
    ProviderScope(
      overrides: [
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = ref.watch(brandThemeProvider);
    final router = ref.watch(appRouter);

    // Set up deep link handling after the app builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initialize deep link handler
      DeepLinkHandler.initialize(context);

      // Set up notification handlers
      final notificationService = ref.read(notificationServiceProvider);

      // Get initial message from FCM
      FirebaseMessaging.instance.getInitialMessage().then((initialMessage) {
        if (initialMessage != null && context.mounted) {
          notificationService.checkPendingNotificationNavigation(context);
        }
      });

      // Listen for background messages being opened
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (context.mounted) {
          final data = Map<String, dynamic>.from(message.data);
          _navigateBasedOnMessageData(data, context);
        }
      });
    });

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: AppConfig.isDevelopment,
        title: AppConfig.appName,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: brand.primaryColor),
          useMaterial3: true,
          fontFamily: 'Inter',
        ),
        routerConfig: router,
        supportedLocales: const [Locale('en')],
        locale: const Locale('en'),
      ),
    );
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

            GoRouter.of(context).go(
              '/payment-result',
              extra: {
                'eventId': itemId,
                'isSuccess': isSuccess,
                'sessionId': sessionId,
              },
            );
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
}
