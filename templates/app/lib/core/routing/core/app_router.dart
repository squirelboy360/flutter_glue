import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../routes.dart';
import '../../../wrapper.dart';

/// Handles the core routing logic of the application
class AppRouter {
  static final navigatorKey = GlobalKey<NavigatorState>();
  static const _modalChannel = MethodChannel('native_modal_channel');
  static late final GoRouter router;

  /// Initialize the router with all necessary configurations
  static void initialize() {
    router = _createRouter();
    _setupNativeModalHandler();
  }

  /// Create the router with routes from Routes class
  static GoRouter _createRouter() {
    final goRoutes = <GoRoute>[];

    // Convert AppRoutes to GoRoutes
    Routes.routes.forEach((path, route) {
      goRoutes.add(
        GoRoute(
          path: path,
          pageBuilder: (context, state) {
            return wrapper(
              context: context,
              isModal: route.isModal,
              child: route.builder(
                context,
                state.extra as Map<String, dynamic>? ?? {},
              ),
            );
          },
        ),
      );
    });

    return GoRouter(
      navigatorKey: navigatorKey,
      debugLogDiagnostics: true,
      initialLocation: '/',
      routes: goRoutes,
    );
  }

  /// Setup handler for native modal navigation
  static void _setupNativeModalHandler() {
    _modalChannel.setMethodCallHandler(_handleModalMethodCall);
  }

  /// Handle method calls from native side
  static Future<void> _handleModalMethodCall(MethodCall call) async {
    if (call.method == 'setRoute') {
      final arguments = Map<String, String>.from(call.arguments['arguments'] ?? {});
      final route = call.arguments['route'] as String;

      final context = navigatorKey.currentContext;
      if (context != null) {
        debugPrint('Navigating to route: $route with args: $arguments');
        await GoRouter.of(context).push(route, extra: arguments);
      }
    }
  }
}
