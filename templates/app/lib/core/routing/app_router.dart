// lib/core/routing/app_router.dart
import 'package:example_app/core/services/native/navigation/helpers.dart';
import 'package:example_app/core/services/native/navigation/models/native_navigation_config.dart.dart';
import 'package:example_app/core/services/native/utils/constants/deps.dart';
import 'package:example_app/core/services/ui_abstractions/screen.dart';
import 'package:example_app/ui/example_screen.dart';
import 'package:example_app/ui/home_screen.dart';
import 'package:example_app/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

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
        //! your routes here
        GoRoute(
          path: '/',
          builder: (context, state) {
            return Wrapper(child: HomeScreen());
          },
        ),

        GoRoute(
          path: '/license',
          builder: (context, state) {
            return Wrapper(child: LicensePage());
          },
        ),

        GoRoute(
          path: '/example',
          builder: (context, state) {
            final args = state.extra as Map<String, String>? ?? {};
            return Wrapper(
              child: ExampleScreen(
                img: args['img'] ?? '',
                title: args['title'] ?? '',
              ),
            );
          },
        ),

        GoRoute(
          path: '/example',
          builder: (context, state) {
            final args = state.extra as Map<String, String>? ?? {};
            return Wrapper(
              child: ExampleScreen(
                img: args['img'] ?? '',
                title: args['title'] ?? '',
              ),
            );
          },
        ),
        //!  your routes end here
      ],
    );
    // call setupTabs to setup the native tabs
    setupTabs();
    // on navigation change, update the native navigation
    // notify stack
    _modalChannel.setMethodCallHandler(Deps.handleModalMethodCall);
  }
}
