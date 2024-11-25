import 'package:flutter/material.dart';
import '../../../core/services/native/triggers/modal.dart';
import '../routes.dart';
import 'app_router.dart';

/// Handles navigation actions in the app
class RouteHandler {
  /// Global context for deep linking
  static BuildContext? globalContext;

  /// Show a modal route
  static void showModal(
    BuildContext context,
    String route, {
    String? headerTitle,
    Map<String, String>? arguments,
    bool showNativeHeader = true,
    bool showCloseButton = true,
  }) {
    globalContext = context;
    final appRoute = Routes.getRoute(route);
    if (appRoute == null) return;

    if (appRoute.isModal) {
      ModalService.showModalWithRoute(
        context: context,
        route: route,
        arguments: arguments ?? {},
        showNativeHeader: showNativeHeader,
        showCloseButton: showCloseButton,
        headerTitle: headerTitle ?? appRoute.title,
      );
    } else {
      AppRouter.router.push(route, extra: arguments);
    }
  }

  /// Navigate to a route
  static void pushRoute(String route, [Map<String, String>? arguments]) {
    final context = AppRouter.navigatorKey.currentContext;
    if (context == null) return;
    globalContext = context;

    AppRouter.router.push(route, extra: arguments);
  }

  /// Pop the current route
  static void pop<T extends Object?>([T? result]) {
    final context = AppRouter.navigatorKey.currentContext;
    if (context == null) return;

    AppRouter.router.pop(result);
  }
}
