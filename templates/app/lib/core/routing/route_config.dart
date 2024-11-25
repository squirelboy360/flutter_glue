import 'package:flutter/material.dart';

enum RouteType {
  page,
  modal,
}

/// Configuration for a single route in the app
class RouteConfig {
  final String path;
  final String? deepLinkPath;
  final RouteType type;
  final Widget Function(BuildContext, Map<String, dynamic>) builder;
  final Map<String, dynamic> Function(Map<String, String>)? parseParams;

  const RouteConfig({
    required this.path,
    required this.type,
    required this.builder,
    this.deepLinkPath,
    this.parseParams,
  });
}

/// App route configuration that developers can easily modify
class AppRoutes {
  static const home = RouteConfig(
    path: '/',
    type: RouteType.page,
    deepLinkPath: '/home',
    builder: _homeBuilder,
  );

  static const license = RouteConfig(
    path: '/license',
    type: RouteType.modal,
    deepLinkPath: '/license',
    builder: _licenseBuilder,
  );

  static const example = RouteConfig(
    path: '/example',
    type: RouteType.page,
    deepLinkPath: '/example',
    builder: _exampleBuilder,
    parseParams: _parseExampleParams,
  );

  // Add more routes here...

  /// List of all routes in the app
  static final List<RouteConfig> routes = [
    home,
    license,
    example,
  ];

  // Route builders
  static Widget _homeBuilder(BuildContext context, Map<String, dynamic> params) {
    return const HomeScreen();
  }

  static Widget _licenseBuilder(BuildContext context, Map<String, dynamic> params) {
    return const LicenseScreen();
  }

  static Widget _exampleBuilder(BuildContext context, Map<String, dynamic> params) {
    final message = params['message'] as String?;
    return ExampleScreen(message: message);
  }

  // Parameter parsers
  static Map<String, dynamic> _parseExampleParams(Map<String, String> params) {
    return {
      'message': params['message'],
    };
  }
}
