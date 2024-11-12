import 'package:example_app/core/services/native/triggers/modal.dart';
import 'package:flutter/material.dart';

class ModalConfig {

  final Map<String, String> arguments;
  final String presentationStyle;
  final List<String> detents;
  final bool isDismissible;
  final bool showDragIndicator;
  final bool enableSwipeGesture;
  final ModalStyle style;
  final bool showNativeHeader;
  final String? headerTitle;
  final bool showCloseButton;
  final ModalHeaderStyle? headerStyle;

  const ModalConfig({
   
    this.arguments = const {},
    this.presentationStyle = 'sheet',
    this.detents = const ['large'],
    this.isDismissible = true,
    this.showDragIndicator = true,
    this.enableSwipeGesture = true,
    this.style = const ModalStyle(),
    this.showNativeHeader = true,
    this.headerTitle,
    this.showCloseButton = false,
    this.headerStyle,
  });

  Map<String, dynamic> toMap() => {
  
    'arguments': arguments,
    'presentationStyle': presentationStyle,
    'detents': detents,
    'isDismissible': isDismissible,
    'showDragIndicator': showDragIndicator,
    'enableSwipeGesture': enableSwipeGesture,
    'style': style.toMap(),
    'showNativeHeader': showNativeHeader,
    'headerTitle': headerTitle,
    'showCloseButton': showCloseButton,
    if (headerStyle != null) 'headerStyle': headerStyle!.toMap(),
  };
}

class ModalStyle {
  final Color? backgroundColor;
  final Color? barrierColor;
  final double cornerRadius;
  final bool blurBackground;
  final double blurIntensity;

  const ModalStyle({
    this.backgroundColor,
    this.barrierColor,
    this.cornerRadius = 20.0,
    this.blurBackground = false,
    this.blurIntensity = 5.0,
  });

  Map<String, dynamic> toMap() => {
    if (backgroundColor != null) 'backgroundColor': backgroundColor!.value,
    if (barrierColor != null) 'barrierColor': barrierColor!.value,
    'cornerRadius': cornerRadius,
    'blurBackground': blurBackground,
    'blurIntensity': blurIntensity,
  };
}

class ModalHeaderStyle {
  final Color backgroundColor;
  final double height;
  final Color dividerColor;

  const ModalHeaderStyle({
    this.backgroundColor = const Color(0xFFF0F0F0),
    this.height = 60.0,
    this.dividerColor = const Color(0xFFCCCCCC),
  });

  Map<String, dynamic> toMap() => {
    'backgroundColor': backgroundColor.value,
    'height': height,
    'dividerColor': dividerColor.value,
  };
}

// Add Modal Extension for easier usage
extension BuildContextModal on BuildContext {
  Future<T?> showAppModal<T>({
    required String route,
    Map<String, String> arguments = const {},
    String? title,
    bool isDismissible = true,
    Color? backgroundColor,
    ModalStyle? style,
    List<String> detents = const ['large'],
  }) async {
    final modalId = await ModalService.showModalWithRoute(
      ModalConfig(
       
        arguments: arguments,
        headerTitle: title,
        isDismissible: isDismissible,
        showCloseButton: true,
        detents: detents,
        style: style ?? ModalStyle(
          backgroundColor: backgroundColor,
        ),
      ), route: route, arguments: arguments,
    );

    return modalId as T?;
  }
}