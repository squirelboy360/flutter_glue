import 'package:example_app/ui/example_screen.dart';
import 'package:example_app/ui/home_screen.dart';
import 'package:example_app/ui/settings_screen.dart';
import 'package:flutter/material.dart';
import 'core/route_handler.dart';

/// Simple route declaration for the app
class AppRoute {
  final String path;
  final Widget Function(BuildContext, Map<String, dynamic>) builder;
  final bool isModal;
  final String? title;
  final Function(Uri)? onDeepLink;

  const AppRoute({
    required this.path,
    required this.builder,
    this.isModal = false,
    this.title,
    this.onDeepLink,
  });
}

/// App routes configuration
class Routes {
  static final routes = {
    '/': AppRoute(
      path: '/',
      builder: (context, args) => const HomeScreen(),
      onDeepLink: (uri) {
        if (uri.queryParameters['showHello'] == 'true') {
          final message = uri.queryParameters['message'] ?? 'Hello from Deep Link!';
          showDialog(
            context: RouteHandler.globalContext!,
            builder: (context) => AlertDialog(
              title: const Text('Welcome'),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
          return true;
        }
        return false;
      },
    ),
    '/example': AppRoute(
      path: '/example',
      isModal: true,
      builder: (context, args) => ExampleScreen(args: args),
      onDeepLink: (uri) {
        // Example of custom deep link handling
        final title = uri.queryParameters['title'];
        if (title != null) {
          RouteHandler.showModal(
            RouteHandler.globalContext!,
            '/example',
            headerTitle: title,
            arguments: uri.queryParameters,
          );
          return true;
        }
        return false;
      },
    ),
    '/license': AppRoute(
      path: '/license',
      isModal: true,
      builder: (context, args) => const LicensePage(),
    ),
    '/settings': AppRoute(
      path: '/settings',
      isModal: true, 
      builder: (context, args) => SettingsScreen(args: args),
      title: 'Settings', 
      onDeepLink: (uri) {
        // Example: myapp://settings?theme=dark
        final theme = uri.queryParameters['theme'];
        if (theme != null) {
          RouteHandler.showModal(
            RouteHandler.globalContext!,
            '/settings',
            headerTitle: 'Settings',
            arguments: {
              'theme': theme,
              ...uri.queryParameters,
            },
          );
          return true;
        }
        return false;
      },
    ),
  };

  static AppRoute? getRoute(String path) => routes[path];

  /// Handle incoming deep links
  static bool handleDeepLink(Uri uri) {
    final path = uri.path;
    final route = getRoute(path);
    
    if (route == null) return false;

    // Try custom deep link handler first
    if (route.onDeepLink?.call(uri) == true) {
      return true;
    }

    // Default handling
    if (route.isModal) {
      RouteHandler.showModal(
        RouteHandler.globalContext!,
        path,
        arguments: uri.queryParameters,
      );
    } else {
      RouteHandler.pushRoute(path, uri.queryParameters);
    }
    
    return true;
  }
}
