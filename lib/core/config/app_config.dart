import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Application configuration class
/// Contains environment-specific settings and constants
class AppConfig {
  // Private constructor to prevent direct instantiation
  AppConfig._();

  // Flag to track if environment has been loaded
  static bool _envLoaded = false;

  // Default values for configuration
  static const String _defaultAppName = 'White Label Community';
  static const String _defaultAppScheme = 'whitecommunity';
  static const String _defaultDomain = 'whitecommunity.page.link';
  static const String _defaultUriPrefix = 'https://whitecommunity.page.link';
  static const String _defaultEnvironment = 'development';

  // Deep linking configuration
  static DeepLinkConfig deepLinkConfig = DeepLinkConfig();

  // App-wide configuration values with safe fallbacks
  static String get appName => _getSafeEnvValue('APP_NAME', _defaultAppName);
  static String get appScheme =>
      _getSafeEnvValue('APP_SCHEME', _defaultAppScheme);

  // Environment detection with safe fallbacks
  static String get environment => _getSafeEnvValue(
    'ENVIRONMENT',
    kDebugMode ? 'development' : 'production',
  );
  static bool get isProduction => environment == 'production';
  static bool get isStaging => environment == 'staging';
  static bool get isDevelopment => environment == 'development' || kDebugMode;

  // Safe method to get environment values
  static String _getSafeEnvValue(String key, String defaultValue) {
    if (!_envLoaded) {
      return defaultValue;
    }

    try {
      return dotenv.env[key] ?? defaultValue;
    } catch (e) {
      debugPrint('Error accessing env value for $key: $e');
      return defaultValue;
    }
  }

  /// Initialize the app configuration with environment variables
  static Future<void> loadFromEnv() async {
    try {
      // Load environment variables
      await dotenv.load();
      _envLoaded = true;

      // Configure deep link settings from environment
      final domain = _getSafeEnvValue('DEEP_LINK_DOMAIN', _defaultDomain);
      final uriPrefix = _getSafeEnvValue(
        'DEEP_LINK_URI_PREFIX',
        _defaultUriPrefix,
      );

      // Initialize deep link config
      deepLinkConfig = DeepLinkConfig(domain: domain, uriPrefix: uriPrefix);

      debugPrint('AppConfig loaded from environment: $environment');
      debugPrint('Deep Link Domain: ${deepLinkConfig.domain}');
      debugPrint('Deep Link URI Prefix: ${deepLinkConfig.uriPrefix}');
    } catch (e) {
      debugPrint('Failed to load environment variables: $e');
      _envLoaded = false;
      // Use default values
      deepLinkConfig = DeepLinkConfig();
    }
  }

  /// Initialize the app configuration with custom values
  /// This can be used to override environment variables
  static void initialize({String? deepLinkDomain, String? deepLinkUriPrefix}) {
    if (deepLinkDomain != null || deepLinkUriPrefix != null) {
      deepLinkConfig = DeepLinkConfig(
        domain: deepLinkDomain ?? deepLinkConfig.domain,
        uriPrefix: deepLinkUriPrefix ?? deepLinkConfig.uriPrefix,
      );
    }
  }

  /// Get the appropriate deep link domain based on environment
  static String getDeepLinkDomainForEnvironment() {
    if (isDevelopment) {
      // For local development, you might want to use a local server
      return _getSafeEnvValue(
        'DEEP_LINK_DOMAIN',
        kIsWeb ? 'localhost' : '10.0.2.2',
      );
    } else if (isStaging) {
      // For staging environment
      return _getSafeEnvValue(
        'DEEP_LINK_DOMAIN',
        'staging-whitecommunity.page.link',
      );
    } else {
      // For production environment
      return _getSafeEnvValue('DEEP_LINK_DOMAIN', 'whitecommunity.page.link');
    }
  }

  /// Get the appropriate deep link URI prefix based on environment
  static String getDeepLinkUriPrefixForEnvironment() {
    if (isDevelopment) {
      // For local development
      return _getSafeEnvValue('DEEP_LINK_URI_PREFIX', 'http://localhost:8080');
    } else if (isStaging) {
      // For staging environment
      return _getSafeEnvValue(
        'DEEP_LINK_URI_PREFIX',
        'https://staging-whitecommunity.page.link',
      );
    } else {
      // For production environment
      return _getSafeEnvValue(
        'DEEP_LINK_URI_PREFIX',
        'https://whitecommunity.page.link',
      );
    }
  }
}

/// Deep linking configuration
class DeepLinkConfig {
  // The domain used for deep links
  final String domain;

  // The URI prefix for deep links
  final String uriPrefix;

  // Constructor with default values
  DeepLinkConfig({String? domain, String? uriPrefix})
    : domain = domain ?? AppConfig.getDeepLinkDomainForEnvironment(),
      uriPrefix = uriPrefix ?? AppConfig.getDeepLinkUriPrefixForEnvironment();

  // Get the full URI for a deep link path
  Uri getDeepLinkUri(String path, Map<String, String> queryParams) {
    final uri = Uri.parse(uriPrefix);

    return Uri(
      scheme: uri.scheme,
      host: domain,
      path: path,
      queryParameters: queryParams,
    );
  }

  // Get the string representation of a deep link URI
  String getDeepLinkString(String path, Map<String, String> queryParams) {
    return getDeepLinkUri(path, queryParams).toString();
  }

  // Payment success deep link
  String getPaymentSuccessLink(String eventId, String sessionId) {
    return getDeepLinkString('/payment-success', {
      'eventId': eventId,
      'sessionId': sessionId,
      'status': 'success',
    });
  }

  // Payment cancel deep link
  String getPaymentCancelLink(String eventId) {
    return getDeepLinkString('/payment-cancel', {
      'eventId': eventId,
      'status': 'cancel',
    });
  }
}

/// Provider for the deep link configuration
final deepLinkConfigProvider = Provider<DeepLinkConfig>((ref) {
  return AppConfig.deepLinkConfig;
});
