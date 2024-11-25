import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import '../routing/core/route_handler.dart';

/// A service to handle deep linking functionality
class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final _appLinks = AppLinks();

  /// Initialize the deep link service
  Future<void> initialize() async {
    // Handle deep link when app is started from terminated state
    try {
      final uri = await _appLinks.getInitialAppLink();
      if (uri != null) {
        RouteHandler.handleDeepLink(uri);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting initial deep link: $e');
      }
    }

    // Handle deep link when app is in background or foreground
    _appLinks.uriLinkStream.listen(
      RouteHandler.handleDeepLink,
      onError: (err) {
        if (kDebugMode) {
          print('Error handling deep link: $err');
        }
      },
    );
  }
}
