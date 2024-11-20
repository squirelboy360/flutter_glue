import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

Page<dynamic> wrapper({
  required Widget child,
  bool? isModal = false,
}) {
  Widget wrappedChild = child;
  if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
    wrappedChild = PrimaryScrollController(
      controller: ScrollController(),
      child: Builder(
        builder: (context) => Scrollbar(
          controller: PrimaryScrollController.of(context),
          interactive: true,
          child: child,
        ),
      ),
    );
  }

  final content = FTheme(
    data: FThemes.zinc.light,
    child: FScaffold(
      content: wrappedChild,
      contentPad: false,
    ),
  );

  return isModal!
      ? NoTransitionPage(child: MaterialApp(home: content))
      : MaterialPage(child: content);
}
