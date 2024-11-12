import 'package:flutter/material.dart';

enum ModalPresentationStyle {
  sheet,
  formSheet,
  fullScreen,
}

class ModalConfiguration {
  final ModalPresentationStyle presentationStyle;
  final List<String> detents;
  final bool isDismissible;
  final bool showDragIndicator;
  final bool enableSwipeGesture;
  final Color? backgroundColor;

  const ModalConfiguration({
    this.presentationStyle = ModalPresentationStyle.sheet,
    this.detents = const ['large'],
    this.isDismissible = true,
    this.showDragIndicator = true,
    this.enableSwipeGesture = true,
    this.backgroundColor,
  });

  Map<String, dynamic> toMap() => {
    'presentationStyle': presentationStyle.name,
    'detents': detents,
    'isDismissible': isDismissible,
    'showDragIndicator': showDragIndicator,
    'enableSwipeGesture': enableSwipeGesture,
    if (backgroundColor != null) 'backgroundColor': backgroundColor!.value,
  };
}
