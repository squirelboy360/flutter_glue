import 'package:example_app/ui/example_screen.dart';
import 'package:example_app/ui/home_screen.dart';
import 'package:flutter/material.dart';

import 'core/app_router.dart';



/// App routes configuration
class Routes {
  static final routes = {
    '/': AppRoute(
      path: '/',
      builder: (context, args) => const HomeScreen(),
    ),
    '/example': AppRoute(
      path: '/example',
      isModal: true,
      builder: (context, args) => ExampleScreen(args: args),
    ),
    '/license': AppRoute(
      path: '/license',
      isModal: true,
      builder: (context, args) => const LicensePage(),
    ),
  };

  /// Get route by path
  static AppRoute? getRoute(String path) => routes[path];
}
