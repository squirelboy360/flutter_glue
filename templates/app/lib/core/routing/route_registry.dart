import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RouteRegistry {
  static final RouteRegistry _instance = RouteRegistry._internal();
  factory RouteRegistry() => _instance;
  RouteRegistry._internal();

  final Map<String, Widget Function(BuildContext, Map<String, String>)> _routeBuilders = {};

  void registerRoute(String path, Widget Function(BuildContext, Map<String, String>) builder) {
    // Store paths with leading slash
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    _routeBuilders[normalizedPath] = builder;
  }

  List<RouteBase> getGoRoutes() {
    return [
      // Root route
      GoRoute(
        path: '/',
        builder: (context, state) {
          final args = state.extra as Map<String, String>? ?? {};
          return _routeBuilders['/']!(context, args);
        },
      ),
      // Other routes
      for (final entry in _routeBuilders.entries)
        if (entry.key != '/')
          GoRoute(
            // GoRouter expects paths without leading slash except for root
            path: entry.key.substring(1),
            builder: (context, state) {
              final args = state.extra as Map<String, String>? ?? {};
              return entry.value(context, args);
            },
          ),
    ];
  }
}