import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/config/app_config.dart';
import 'dart:io';

// Simple app to test deep link configuration
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check if .env file exists and print current directory info
  try {
    final currentDir = Directory.current;
    debugPrint('Current directory: ${currentDir.path}');

    final envFile = File('${currentDir.path}/.env');
    final exists = await envFile.exists();
    debugPrint('.env file exists: $exists');

    if (exists) {
      debugPrint('.env file path: ${envFile.path}');

      // Try to read the file to see if there are permission issues
      try {
        final content = await envFile.readAsString();
        debugPrint('.env file content length: ${content.length}');
      } catch (e) {
        debugPrint('Error reading .env file: $e');
      }
    }

    // Try to load with dotenv
    try {
      await dotenv.load(fileName: ".env");
      debugPrint('dotenv loaded successfully');
    } catch (e) {
      debugPrint('Error loading dotenv: $e');
      // Set default values manually if .env fails to load
      Map<String, String> defaultEnv = {
        'APP_NAME': 'White Label Community',
        'APP_SCHEME': 'whitecommunity',
        'ENVIRONMENT': 'development',
        'DEEP_LINK_DOMAIN': 'whitecommunity.page.link',
        'DEEP_LINK_URI_PREFIX': 'https://whitecommunity.page.link',
      };

      for (var entry in defaultEnv.entries) {
        dotenv.env[entry.key] = entry.value;
      }
      debugPrint('Using default environment values instead');
    }

    await AppConfig.loadFromEnv();

    runApp(const DeepLinkTestApp());
  } catch (e) {
    debugPrint('Unexpected error: $e');
    // Run with defaults anyway
    runApp(const DeepLinkTestApp());
  }
}

class DeepLinkTestApp extends StatelessWidget {
  const DeepLinkTestApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Deep Link Tester')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Environment Values:'),
              Text('APP_NAME: ${AppConfig.appName}'),
              Text('APP_SCHEME: ${AppConfig.appScheme}'),
              Text('Environment: ${AppConfig.environment}'),
              const SizedBox(height: 20),
              const Text('Deep Link Configuration:'),
              Text('Domain: ${AppConfig.deepLinkConfig.domain}'),
              Text('URI Prefix: ${AppConfig.deepLinkConfig.uriPrefix}'),
              const SizedBox(height: 20),
              const Text('Example Deep Links:'),
              _DeepLinkExample(
                title: 'Basic Path',
                path: '/events',
                params: {'category': 'sports'},
              ),
              _DeepLinkExample(
                title: 'Payment Success',
                path: '/payment-success',
                params: {
                  'eventId': '12345',
                  'sessionId': 'sess_123',
                  'status': 'success',
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeepLinkExample extends StatelessWidget {
  final String title;
  final String path;
  final Map<String, String> params;

  const _DeepLinkExample({
    required this.title,
    required this.path,
    required this.params,
  });

  @override
  Widget build(BuildContext context) {
    final deepLinkUri = AppConfig.deepLinkConfig.getDeepLinkUri(path, params);
    final deepLinkString = AppConfig.deepLinkConfig.getDeepLinkString(
      path,
      params,
    );

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$title:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('URI: $deepLinkUri'),
            const SizedBox(height: 4),
            Text('String: $deepLinkString'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Copied: $deepLinkString')),
                );
              },
              child: const Text('Copy Link'),
            ),
          ],
        ),
      ),
    );
  }
}
