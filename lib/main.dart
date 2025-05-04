import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:white_label_community_app/core/services/notification_service.dart';
import 'package:white_label_community_app/core/theme/brand_theme.dart';
import 'router/app_router.dart';
import 'firebase_options.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background message
  print('BG message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await NotificationService().init();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = ref.watch(brandThemeProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: '${brand.name} Events',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: brand.primaryColor),
          useMaterial3: true,
          fontFamily: 'Inter',
        ),
        routerConfig: ref.watch(appRouter),
        supportedLocales: const [Locale('en')],
        locale: const Locale('en'),
      ),
    );
  }
}
