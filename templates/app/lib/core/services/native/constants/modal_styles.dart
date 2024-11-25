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
enum ModalDetent {
  /// Large height (90% of screen)
  large(0.9),
  
  /// Medium height (50% of screen)
  medium(0.5),
  
  /// Small peek at bottom (25% of screen)
  small(0.25),
  
  /// Custom height
  custom(0.0);

  final double height;
  const ModalDetent(this.height);
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
  /// Presentation style for the modal
  final ModalPresentationStyle presentationStyle;
  
  /// Transition style for the modal
  final ModalTransitionStyle transitionStyle;

  /// Whether the modal is dismissible
  final bool isDismissible;
  
  /// Whether to enable swipe gesture
  final bool enableSwipeGesture;
  
  /// Whether to show drag indicator
  final bool showDragIndicator;
  
  /// Corner radius for the modal
  final double? cornerRadius;
  
  /// Background color (using Color)
  final Color? backgroundColor;
  
  /// Padding for the modal
  final EdgeInsets padding;
  
  /// Whether to use rounded corners
  final bool roundedCorners;
  
  /// Custom height for the modal
  final double? customHeight;

  /// Whether to blur the background
  final bool blurBackground;

  /// Blur intensity (0.0 to 1.0)
  final double blurIntensity;

  /// Background opacity (0.0 to 1.0)
  final double backgroundOpacity;

  /// Animation duration
  final Duration? animationDuration;

  /// Header styling for the modal
  final ModalHeaderStyle? headerStyle;

  /// Swipe dismiss direction
  final SwipeDismissDirection swipeDismissDirection;
  
  /// List of detents for the modal
  final List<ModalDetent> detents;
  
  /// Initial detent for the modal
  final ModalDetent initialDetent;
  
  /// Custom detent height for the modal
  final double? customDetentHeight;
  
  /// Text for the done button
  final String? doneButtonText;
  
  /// Callback for when the done button is pressed
  final VoidCallback? onDonePressed;
  
  /// Callback for when the modal is dismissed
  final VoidCallback? onDismissed;
  
  /// Callback for when the modal is presented
  final VoidCallback? onPresented;
  
  /// Callback for when the modal will be dismissed
  final Future<bool> Function()? onWillDismiss;

  const ModalConfiguration({
    this.presentationStyle = ModalPresentationStyle.sheet,
    this.transitionStyle = ModalTransitionStyle.coverVertical,
    this.isDismissible = true,
    this.enableSwipeGesture = true,
    this.showDragIndicator = true,
    this.cornerRadius = 12.0,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(16.0),
    this.roundedCorners = true,
    this.customHeight,
    this.blurBackground = false,
    this.blurIntensity = 0.5,
    this.backgroundOpacity = 0.5,
    this.animationDuration,
    this.headerStyle,
    this.swipeDismissDirection = SwipeDismissDirection.down,
    this.detents = const [ModalDetent.large],
    this.initialDetent = ModalDetent.large,
    this.customDetentHeight,
    this.doneButtonText,
    this.onDonePressed,
    this.onDismissed,
    this.onPresented,
    this.onWillDismiss,
  });
}