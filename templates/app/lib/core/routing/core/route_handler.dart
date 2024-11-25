import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../services/native/triggers/modal.dart';

/// Handles navigation based on route type
class RouteHandler {
  /// Handle deep link or regular navigation
  static void showModal(
    BuildContext context,
    String route, {
    String? headerTitle,
    Map<String, String>? arguments,
    bool showNativeHeader = true,
    bool showCloseButton = true,
  }) {
    ModalService.showModalWithRoute(
      context: context,
      route: route,
      arguments: arguments ?? {},
      showNativeHeader: showNativeHeader,
      showCloseButton: showCloseButton,
      headerTitle: headerTitle,
    );
  }

  /// Handle deep link navigation
  static void handleDeepLink(Uri uri) {
    final isModal = uri.queryParameters['isModal']?.toLowerCase() == 'true';
    if (isModal) {
      // Modal deep links will be handled when context is available
      if (kDebugMode) {
        print('Modal deep link received: $uri');
      }
    }
  }
}
