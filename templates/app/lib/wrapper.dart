import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:example_app/core/services/native/navigation/native_navigation_service.dart';

class Wrapper extends StatelessWidget {
  final Widget child;
  
  const Wrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    key: UniqueKey(),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: NoTransitionsBuilder(),
            TargetPlatform.iOS: NoTransitionsBuilder(),
            TargetPlatform.macOS: NoTransitionsBuilder(),
            TargetPlatform.windows: NoTransitionsBuilder(),
            TargetPlatform.linux: NoTransitionsBuilder(),
          },
        ),
      ),
      builder: (context, child) => FTheme(
        data: FThemes.zinc.light,
        child: ValueListenableBuilder<NavigationBar?>(
          valueListenable: NativeNavigationService.navigationBar,
          builder: (context, navigationBar, child) => FScaffold(
            content: !kIsWeb & Platform.isIOS || Platform.isAndroid
              ? PrimaryScrollController(
                  controller: ScrollController(),
                  child: Builder(
                    builder: (context) => Scrollbar(
                      controller: PrimaryScrollController.of(context),
                      interactive: true,
                      child: child!,
                    ),
                  ),
                )
              : child!,
            footer: !Platform.isIOS ? navigationBar : null,
            contentPad: false,
          ),
          child: child,
        ),
      ),
      home: child,
    ),
  );
}

class NoTransitionsBuilder extends PageTransitionsBuilder {
  const NoTransitionsBuilder();
  
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}