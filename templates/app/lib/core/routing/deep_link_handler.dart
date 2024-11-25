import 'package:example_app/core/routing/core/app_router.dart';
import 'package:flutter/material.dart';
import '../services/native/triggers/modal.dart';
import 'routes.dart';

/// Handles deep link navigation
class DeepLinkHandler {
  /// Handle deep link URI
  static void handleDeepLink(BuildContext? context, Uri uri) {
    final route = Routes.getRoute(uri.path);
    if (route == null) return;

    final args = uri.queryParameters;
    
    if (context != null && route.isModal) {
      // Show as modal if it's a modal route
      ModalService.showModalWithRoute(
        context: context,
        route: route.path,
        arguments: args,
        showNativeHeader: true,
        showCloseButton: true,
        headerTitle: route.title ?? args['title'],
      );
    } else {
      // Navigate using go_router for regular pages
      AppRouter.router.push(route.path, extra: args);
    }
  }
}
