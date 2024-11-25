import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/deep_link_service.dart';
import 'route_config.dart';

class RoutingService {
  static final RoutingService _instance = RoutingService._internal();
  factory RoutingService() => _instance;
  RoutingService._internal();

  late final GoRouter router;
  final _deepLinkService = DeepLinkService();

  void initialize() {
    router = _createRouter();
    _initializeDeepLinks();
  }

  GoRouter _createRouter() {
    final routes = <RouteBase>[];

    // Create routes from configuration
    for (final config in AppRoutes.routes) {
      if (config.type == RouteType.page) {
        routes.add(
          GoRoute(
            path: config.path,
            builder: (context, state) => config.builder(
              context,
              _parseRouteParams(config, state.queryParameters),
            ),
          ),
        );
      } else if (config.type == RouteType.modal) {
        routes.add(
          GoRoute(
            path: config.path,
            pageBuilder: (context, state) => MaterialPage(
              fullscreenDialog: true,
              child: config.builder(
                context,
                _parseRouteParams(config, state.queryParameters),
              ),
            ),
          ),
        );
      }
    }

    return GoRouter(
      routes: routes,
      errorBuilder: (context, state) => const Scaffold(
        body: Center(
          child: Text('Page not found'),
        ),
      ),
    );
  }

  void _initializeDeepLinks() {
    _deepLinkService.initialize();
    _deepLinkService.deepLinkStream.listen(_handleDeepLink);
  }

  void _handleDeepLink(Uri uri) {
    final path = uri.path;
    final params = uri.queryParameters;

    // Find matching route config
    final config = AppRoutes.routes.firstWhere(
      (route) => route.deepLinkPath == path,
      orElse: () => AppRoutes.home,
    );

    // Navigate using go_router
    router.push(config.path + _buildQueryString(params));
  }

  Map<String, dynamic> _parseRouteParams(
    RouteConfig config,
    Map<String, String> params,
  ) {
    if (config.parseParams != null) {
      return config.parseParams!(params);
    }
    return params.map((key, value) => MapEntry(key, value));
  }

  String _buildQueryString(Map<String, String> params) {
    if (params.isEmpty) return '';
    return '?' + params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  // Navigation helpers
  void pushRoute(String path, [Map<String, String>? params]) {
    router.push(path + _buildQueryString(params ?? {}));
  }

  void pushModal(String path, [Map<String, String>? params]) {
    final config = AppRoutes.routes.firstWhere(
      (route) => route.path == path,
      orElse: () => throw Exception('Modal route not found: $path'),
    );

    if (config.type != RouteType.modal) {
      throw Exception('Route is not a modal: $path');
    }

    router.push(path + _buildQueryString(params ?? {}));
  }

  void pop<T extends Object?>([T? result]) {
    router.pop(result);
  }
}
