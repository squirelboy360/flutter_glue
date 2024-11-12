import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class Deps {
  static late final GoRouter router;
  static final navigatorKey = GlobalKey<NavigatorState>();
  static Future<void> handleModalMethodCall(MethodCall call) async {
    if (call.method == 'setRoute') {
      final arguments =
          Map<String, String>.from(call.arguments['arguments'] ?? {});
      final route = call.arguments['route'] as String;
      final context = navigatorKey.currentContext;

      if (context != null) {
        debugPrint('Navigating to route: $route with args: $arguments');
        router.go(route, extra: arguments);
      }
    }
  }

  static String? getCurrentPath() {
    final location = router.routeInformationProvider.value.uri.toString();
    return location != '/' ? location : null;
  }
}
