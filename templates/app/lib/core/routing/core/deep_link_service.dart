import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import '../routes.dart';

/// Handles deep linking functionality
class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final _appLinks = AppLinks();

  /// Initialize deep link handling
  Future<void> initialize() async {
    // Handle app launch from deep link
    try {
      final uri = await _appLinks.getInitialAppLink();
      if (uri != null) {
        final route = Routes.handleDeepLink(uri);
        if (kDebugMode) {
          print('Initial deep link handled: $uri');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error handling initial deep link: $e');
      }
    }

    // Handle deep links while app is running
    _appLinks.uriLinkStream.listen(
      (uri) {
        Routes.handleDeepLink(uri);
        if (kDebugMode) {
          print('Deep link handled: $uri');
        }
      },
      onError: (err) {
        if (kDebugMode) {
          print('Error handling deep link: $err');
        }
      },
    );
  }
}
