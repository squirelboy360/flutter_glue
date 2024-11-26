import 'package:flutter/material.dart';
import 'package:example_app/core/services/native/triggers/modal.dart';
import 'package:example_app/core/services/native/constants/modal_styles.dart';
import 'package:example_app/core/routing/routes.dart';
import 'package:example_app/core/routing/core/app_router.dart';

/// Handles route and modal navigation
class RouteHandler {
  /// Global context for navigation
  static BuildContext? globalContext;

  /// Build a widget for the given route
  static Widget buildRoute(String route, Map<String, dynamic> arguments) {
    debugPrint('Building route: $route with arguments: $arguments');
    final routeConfig = Routes.getRoute(route);
    if (routeConfig == null) {
      debugPrint('Route not found: $route');
      return const SizedBox(); // Return empty widget if route not found
    }
    return routeConfig.builder(
      globalContext ?? AppRouter.navigatorKey.currentContext!,
      Map<String, String>.from(arguments),
    );
  }

  /// Show a modal with the given route
  static void showModal(
    BuildContext context,
    String route, {
    String? headerTitle,
    Map<String, String>? arguments,
    bool showNativeHeader = true,
    bool showCloseButton = true,
    ModalConfiguration? configuration,
  }) {
    ModalService.showModalWithRoute(
      context: context,
      route: route,
      arguments: arguments ?? {},
      showNativeHeader: showNativeHeader,
      showCloseButton: showCloseButton,
      headerTitle: headerTitle,
      configuration: configuration ?? const ModalConfiguration(
        presentationStyle: ModalPresentationStyle.sheet,
        detents: [ModalDetent.medium, ModalDetent.large],
        initialDetent: ModalDetent.medium,
        isDismissible: true,
        enableSwipeGesture: true,
        showDragIndicator: true,
      ),
    );
  }

  /// Push a new route
  static void pushRoute(String path, [Map<String, String>? params]) {
    if (globalContext == null) return;
    
    final args = params ?? {};
    Navigator.of(globalContext!).pushNamed(path, arguments: args);
  }
}
