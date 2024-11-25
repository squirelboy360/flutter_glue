import 'package:flutter/material.dart';
import 'package:example_app/core/services/native/triggers/modal.dart';

/// Handles route and modal navigation
class RouteHandler {
  /// Global context for navigation
  static BuildContext? globalContext;

  /// Show a modal with the given route
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

  /// Push a new route
  static void pushRoute(String path, [Map<String, String>? params]) {
    if (globalContext == null) return;
    
    final args = params ?? {};
    Navigator.of(globalContext!).pushNamed(path, arguments: args);
  }
}
