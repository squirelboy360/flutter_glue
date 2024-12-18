import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// Wraps pages with consistent transition animations
Page<dynamic> wrapper({
  required BuildContext context,
  required Widget child,
  bool isModal = false,
}) {
  final theme = Theme.of(context);
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

  final content = Theme(
    data: theme,
    child: FTheme(
      data: theme.brightness == Brightness.dark
          ? FThemes.zinc.dark
          : FThemes.zinc.light,
      child: Builder(
        builder: (context) => wrappedChild,
      ),
    ),
  );

  if (isModal) {
    return MaterialPage(
      fullscreenDialog: true,
      child: Theme(
        data: theme,
        child: content,
      ),
    );
  }
  return MaterialPage(child: content);
}
