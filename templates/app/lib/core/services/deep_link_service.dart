import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

/// A service to handle deep linking functionality.
/// This service can be easily customized for different apps using the template.
class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final _appLinks = AppLinks();
  final _deepLinkStreamController = StreamController<Uri>.broadcast();

  /// Stream of deep link events that can be listened to
  Stream<Uri> get deepLinkStream => _deepLinkStreamController.stream;

  /// Initialize the deep link service
  Future<void> initialize() async {
    // Handle deep link when app is started from terminated state
    try {
      final uri = await _appLinks.getInitialAppLink();
      if (uri != null) {
        _handleDeepLink(uri);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting initial deep link: $e');
      }
    }

    // Handle deep link when app is in background or foreground
    _appLinks.uriLinkStream.listen(
      (uri) => _handleDeepLink(uri),
      onError: (err) {
        if (kDebugMode) {
          print('Error handling deep link: $err');
        }
      },
    );
  }

  /// Handle incoming deep link
  /// Override this method in your app-specific implementation
  void _handleDeepLink(Uri uri) {
    // Example deep link handling
    switch (uri.path) {
      case '/example':
        // Handle example deep link
        if (kDebugMode) {
          print('Handling example deep link: $uri');
          print('Parameters: ${uri.queryParameters}');
        }
        break;
      case '/share':
        // Handle share deep link
        if (kDebugMode) {
          print('Handling share deep link: $uri');
          print('Parameters: ${uri.queryParameters}');
        }
        break;
      default:
        if (kDebugMode) {
          print('Unhandled deep link: $uri');
        }
    }

    // Broadcast the deep link to any listeners
    _deepLinkStreamController.add(uri);
  }

  /// Dispose of resources
  void dispose() {
    _deepLinkStreamController.close();
  }
}
