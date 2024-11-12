import 'package:example_app/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../ui/example_screen.dart';
import '../../ui/home_screen.dart';

// Global navigator key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final navigatorKey = GlobalKey<NavigatorState>();
  static const _modalChannel = MethodChannel('native_modal_channel');

  static late final GoRouter router;

  static void initialize() {
    router = GoRouter(
      navigatorKey: navigatorKey,
      debugLogDiagnostics: true,
      initialLocation: '/',
      routes: [
        // routes go here
        GoRoute(
          path: '/license',
          builder: (context, state) {
            // because the arguments passed fromm dart to dart you don't need to cast the extra to Map<String, String> but you can do it if you want especially if you don't want
            // to be limited to accessing native UI in the future.
            // final args = state.extra as Map<String, String>? ?? {};
            return const Wrapper(child: LicensePage());
          },
        ),
        GoRoute(
          path: '/',
          builder: (context, state) {
            // because the arguments passed fromm dart to dart you don't need to cast the extra to Map<String, String> but you can do it if you want especially if you don't want
            // to be limited to accessing native UI in the future.
            // final args = state.extra as Map<String, String>? ?? {};
            return const Wrapper(child: HomeScreen());
          },
        ),
        GoRoute(
          path: '/example',
          builder: (context, state) {
            // pass arguments to the screen
            final args = state.extra as Map<String, String>? ?? {};
            return Wrapper(
              child: ExampleScreen(
                img: args['img'] ?? '',
                title: args['title'] ?? '',
              ),
            );
          },
        ),

        //
      ],
    );
    // don't remove these lines. More native UI will be added in the future
    _modalChannel.setMethodCallHandler(_handleModalMethodCall);
  }

  static Future<void> _handleModalMethodCall(MethodCall call) async {
    if (call.method == 'setRoute') {
      final arguments =
          Map<String, String>.from(call.arguments['arguments'] ?? {});
      final route = call.arguments['route'] as String;

      final context = navigatorKey.currentContext;
      if (context != null) {
        debugPrint('Navigating to route: $route with args: $arguments');
        await GoRouter.of(context).push(route, extra: arguments);
      }
    }
  }
}
