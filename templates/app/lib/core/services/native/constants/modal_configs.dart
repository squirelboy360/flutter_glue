import 'package:flutter/material.dart';
import 'modal_styles.dart';

/// Modal header style configuration
class ModalHeaderStyle {
  final Color? backgroundColor;
  final Color? dividerColor;
  final double? height;
  final bool showDivider;

  const ModalHeaderStyle({
    this.backgroundColor,
    this.dividerColor,
    this.height,
    this.showDivider = true,
  });

  ModalHeaderStyle copyWith({
    Color? backgroundColor,
    Color? dividerColor,
    double? height,
    bool? showDivider,
  }) {
    return ModalHeaderStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      dividerColor: dividerColor ?? this.dividerColor,
      height: height ?? this.height,
      showDivider: showDivider ?? this.showDivider,
    );
  }
}

/// Modal configuration
class ModalConfiguration {
  final ModalPresentationStyle presentationStyle;
  final List<ModalDetent>? detents;
  final ModalDetent? initialDetent;
  final double? customDetentHeight;
  final ModalTransitionStyle? transitionStyle;
  final bool isDismissible;
  final bool enableSwipeGesture;
  final SwipeDismissDirection? swipeDismissDirection;
  final bool showDragIndicator;
  final double cornerRadius;
  final Color? backgroundColor;
  final ModalHeaderStyle? headerStyle;
  final Future<bool> Function()? onWillDismiss;
  final VoidCallback? onDismissed;
  final VoidCallback? onPresented;

  const ModalConfiguration({
    this.presentationStyle = ModalPresentationStyle.sheet,
    this.detents,
    this.initialDetent,
    this.customDetentHeight,
    this.transitionStyle,
    this.isDismissible = true,
    this.enableSwipeGesture = true,
    this.swipeDismissDirection,
    this.showDragIndicator = true,
    this.cornerRadius = 12.0,
    this.backgroundColor,
    this.headerStyle,
    this.onWillDismiss,
    this.onDismissed,
    this.onPresented,
  });

  ModalConfiguration copyWith({
    ModalPresentationStyle? presentationStyle,
    List<ModalDetent>? detents,
    ModalDetent? initialDetent,
    double? customDetentHeight,
    ModalTransitionStyle? transitionStyle,
    bool? isDismissible,
    bool? enableSwipeGesture,
    SwipeDismissDirection? swipeDismissDirection,
    bool? showDragIndicator,
    double? cornerRadius,
    Color? backgroundColor,
    ModalHeaderStyle? headerStyle,
    Future<bool> Function()? onWillDismiss,
    VoidCallback? onDismissed,
    VoidCallback? onPresented,
  }) {
    return ModalConfiguration(
      presentationStyle: presentationStyle ?? this.presentationStyle,
      detents: detents ?? this.detents,
      initialDetent: initialDetent ?? this.initialDetent,
      customDetentHeight: customDetentHeight ?? this.customDetentHeight,
      transitionStyle: transitionStyle ?? this.transitionStyle,
      isDismissible: isDismissible ?? this.isDismissible,
      enableSwipeGesture: enableSwipeGesture ?? this.enableSwipeGesture,
      swipeDismissDirection: swipeDismissDirection ?? this.swipeDismissDirection,
      showDragIndicator: showDragIndicator ?? this.showDragIndicator,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      headerStyle: headerStyle ?? this.headerStyle,
      onWillDismiss: onWillDismiss ?? this.onWillDismiss,
      onDismissed: onDismissed ?? this.onDismissed,
      onPresented: onPresented ?? this.onPresented,
    );
  }
}
