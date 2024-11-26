import 'package:flutter/material.dart';

/// Different ways a modal can be presented
enum ModalPresentationStyle {
  /// Bottom sheet style (iOS: .pageSheet, Others: BottomSheet)
  sheet,
  
  /// Full screen modal
  fullScreen,
  
  /// Center form sheet
  formSheet,
  
  /// Side sheet from right
  pageSheet,
}

/// Modal transition styles
enum ModalTransitionStyle {
  /// Default transition
  coverVertical,
  
  /// Fade transition
  fade,
  
  /// Cross dissolve
  crossDissolve,
}

/// Swipe dismiss directions
enum SwipeDismissDirection {
  /// Dismiss by swiping down
  down,
  
  /// Dismiss by swiping up
  up,
  
  /// No swipe dismiss
  none,
}

/// Sheet size configurations
class ModalDetent {
  /// Large height (90% of screen)
  static const large = ModalDetent._('large', 0.9);
  
  /// Medium height (60% of screen)
  static const medium = ModalDetent._('medium', 0.6);
  
  /// Small peek at bottom (30% of screen)
  static const small = ModalDetent._('small', 0.3);
  
  /// Custom height (specify percentage between 0.0 and 1.0)
  static ModalDetent custom(double percentage) {
    assert(percentage > 0.0 && percentage <= 1.0, 'Percentage must be between 0.0 and 1.0');
    return ModalDetent._('custom', percentage);
  }

  final String name;
  final double height;
  const ModalDetent._(this.name, this.height);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModalDetent &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          height == other.height;

  @override
  int get hashCode => name.hashCode ^ height.hashCode;
}

/// Header styling for modals
class ModalHeaderStyle {
  /// Background color for the header
  final Color? backgroundColor;
  
  /// Height of the header
  final double? height;
  
  /// Color of the divider
  final Color? dividerColor;
  
  /// Whether to show the divider
  final bool showDivider;

  /// Elevation of the header
  final double? elevation;

  /// Effective background color considering theme
  Color? get effectiveBackgroundColor => backgroundColor;

  const ModalHeaderStyle({
    this.backgroundColor,
    this.height,
    this.dividerColor,
    this.showDivider = true,
    this.elevation,
  });
}

/// Complete modal configuration
class ModalConfiguration {
  /// Presentation style of the modal
  final ModalPresentationStyle presentationStyle;
  
  /// Transition style for presenting/dismissing
  final ModalTransitionStyle? transitionStyle;
  
  /// Available detents (sizes) for the modal
  final List<ModalDetent> detents;
  
  /// Initial detent to show
  final ModalDetent? initialDetent;
  
  /// Whether modal can be dismissed
  final bool isDismissible;
  
  /// Whether to show drag indicator
  final bool showDragIndicator;
  
  /// Whether swipe gesture is enabled
  final bool enableSwipeGesture;
  
  /// Direction for swipe dismiss
  final SwipeDismissDirection swipeDismissDirection;
  
  /// Background color of modal
  final Color? backgroundColor;
  
  /// Corner radius of modal
  final double? cornerRadius;
  
  /// Header styling
  final ModalHeaderStyle? headerStyle;
  
  /// Whether to show native header
  final bool showNativeHeader;
  
  /// Whether to show close button
  final bool showCloseButton;
  
  /// Header title text
  final String? headerTitle;
  
  /// Called before dismissal
  final Future<bool> Function()? onWillDismiss;
  
  /// Called after dismissal
  final VoidCallback? onDismissed;
  
  /// Called after presentation
  final VoidCallback? onPresented;

  const ModalConfiguration({
    this.presentationStyle = ModalPresentationStyle.sheet,
    this.transitionStyle,
    this.detents = const [ModalDetent.medium],
    this.initialDetent,
    this.isDismissible = true,
    this.showDragIndicator = true,
    this.enableSwipeGesture = true,
    this.swipeDismissDirection = SwipeDismissDirection.down,
    this.backgroundColor,
    this.cornerRadius,
    this.headerStyle,
    this.showNativeHeader = true,
    this.showCloseButton = true,
    this.headerTitle,
    this.onWillDismiss,
    this.onDismissed,
    this.onPresented,
  });

  /// Creates a copy of this configuration with the given fields replaced with the new values
  ModalConfiguration copyWith({
    ModalPresentationStyle? presentationStyle,
    ModalTransitionStyle? transitionStyle,
    List<ModalDetent>? detents,
    ModalDetent? initialDetent,
    bool? isDismissible,
    bool? showDragIndicator,
    bool? enableSwipeGesture,
    SwipeDismissDirection? swipeDismissDirection,
    Color? backgroundColor,
    double? cornerRadius,
    ModalHeaderStyle? headerStyle,
    bool? showNativeHeader,
    bool? showCloseButton,
    String? headerTitle,
    Future<bool> Function()? onWillDismiss,
    VoidCallback? onDismissed,
    VoidCallback? onPresented,
  }) {
    return ModalConfiguration(
      presentationStyle: presentationStyle ?? this.presentationStyle,
      transitionStyle: transitionStyle ?? this.transitionStyle,
      detents: detents ?? this.detents,
      initialDetent: initialDetent ?? this.initialDetent,
      isDismissible: isDismissible ?? this.isDismissible,
      showDragIndicator: showDragIndicator ?? this.showDragIndicator,
      enableSwipeGesture: enableSwipeGesture ?? this.enableSwipeGesture,
      swipeDismissDirection: swipeDismissDirection ?? this.swipeDismissDirection,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      headerStyle: headerStyle ?? this.headerStyle,
      showNativeHeader: showNativeHeader ?? this.showNativeHeader,
      showCloseButton: showCloseButton ?? this.showCloseButton,
      headerTitle: headerTitle ?? this.headerTitle,
      onWillDismiss: onWillDismiss ?? this.onWillDismiss,
      onDismissed: onDismissed ?? this.onDismissed,
      onPresented: onPresented ?? this.onPresented,
    );
  }
}