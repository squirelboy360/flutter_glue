import 'package:example_app/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../ui/example_screen.dart';
import '../../../ui/home_screen.dart';

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
          pageBuilder: (context, state) {
            return wrapper(
              isModal: true,
              child:const  LicensePage()
            );
          },
        ),
        GoRoute(
          path: '/',
         pageBuilder: (context, state) {
            return wrapper(
              isModal: false,
              child: const HomeScreen(
                
              ),
            );}
        ),
        GoRoute(
          path: '/example',
          pageBuilder: (context, state) {
            return wrapper(
              isModal: true,
              child: ExampleScreen(
                args: state.extra as Map<String, dynamic>? ?? {},
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


/// Simple route declaration for the app
class AppRoute {
  final String path;
  final Widget Function(BuildContext, Map<String, dynamic>) builder;
  final bool isModal;
  final String? title;

  const AppRoute({
    required this.path,
    required this.builder,
    this.isModal = false,
    this.title,
  });
}


