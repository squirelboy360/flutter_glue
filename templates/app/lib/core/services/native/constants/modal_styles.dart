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
  sideSheet,
  
  /// Popup style
  popup;

  const ModalPresentationStyle();
}

/// Modal transition animations
enum ModalTransitionStyle {
  /// Default platform transition
  automatic,
  
  /// Slide up from bottom
  bottomToTop,
  
  /// Fade in/out
  fade,
  
  /// Scale up/down
  zoom,
  
  /// Slide from right/left
  horizontal;

  const ModalTransitionStyle();
}

/// Sheet size configurations
class ModalDetent {
  /// Small peek at bottom (25% of screen)
  static const small = ModalDetent._(0.25);
  
  /// Medium height (50% of screen)
  static const medium = ModalDetent._(0.5);
  
  /// Large height (90% of screen)
  static const large = ModalDetent._(0.9);
  
  /// Full height
  static const full = ModalDetent._(1.0);

  /// The height fraction (0.0 to 1.0)
  final double height;

  /// Create a custom height detent
  const ModalDetent.custom(this.height) : assert(height > 0 && height <= 1.0);
  const ModalDetent._(this.height);
}

/// Swipe/drag gesture configuration
enum SwipeDismissDirection {
  vertical,
  horizontal,
  all,
  none;

  const SwipeDismissDirection();
}

/// Colors for modal presentation
class ModalColors {
  // Platform adaptive colors
  static const defaultBackground = Color(0xFFFFFFFF);
  static const dimmedBackground = Color(0xFFF5F5F5);
  static const darkBackground = Color(0xFF121212);
  static const transparentBackground = Colors.transparent;
  
  // iOS specific colors
  static const iosSheetBackground = Color(0xF0F9F9F9);
  static const iosHeaderBackground = Color(0xFFF8F8F8);
  static const iosDivider = Color(0xFFE0E0E0);
  
  // Material specific colors
  static const materialSheetBackground = Color(0xFFFFFFFF);
  static const materialBarrierColor = Color(0x80000000);
  static const materialHeaderBackground = Color(0xFFFAFAFA);
  
  /// Convert hex string to Color
  /// Accepts formats: '#RRGGBB', '#RRGGBBAA', 'RRGGBB', 'RRGGBBAA'
  static Color? fromHex(String hexString) {
    try {
      final buffer = StringBuffer();
      final hex = hexString.replaceFirst('#', '');
      
      if (hex.length == 6) {
        buffer.write('ff');
        buffer.write(hex);
      } else if (hex.length == 8) {
        buffer.write(hex);
      } else {
        return null;
      }
      
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return null;
    }
  }
}

/// Complete visual styling for modals
class ModalStyle {
  /// Background color (using Color)
  final Color? backgroundColor;
  
  /// Background color (using hex string)
  final String? backgroundHexColor;
  
  /// Corner radius for the modal
  final double? cornerRadius;
  
  /// Whether to blur the background behind the modal
  final bool blurBackground;
  
  /// Background blur intensity (0.0 to 1.0)
  final double blurIntensity;
  
  /// Background opacity (0.0 to 1.0)
  final double backgroundOpacity;
  
  /// Custom shadow
  final BoxShadow? shadow;
  
  /// Material elevation
  final double? elevation;
  
  /// Border styling
  final Border? border;
  
  /// Background gradient
  final Gradient? gradient;
  
  /// Barrier color when modal is shown
  final Color? barrierColor;
  
  /// Whether tapping the barrier dismisses the modal
  final bool barrierDismissible;
  
  /// Animation duration for presenting/dismissing
  final Duration? animationDuration;
  
  /// Whether to maintain state when modal is hidden
  final bool maintainState;
  
  /// Safe area handling
  final bool useSafeArea;

  const ModalStyle({
    this.backgroundColor,
    this.backgroundHexColor,
    this.cornerRadius,
    this.blurBackground = false,
    this.blurIntensity = 0.5,
    this.backgroundOpacity = 1.0,
    this.shadow,
    this.elevation,
    this.border,
    this.gradient,
    this.barrierColor,
    this.barrierDismissible = true,
    this.animationDuration,
    this.maintainState = true,
    this.useSafeArea = true,
  }) : assert(
         backgroundColor == null || backgroundHexColor == null,
         'Cannot specify both backgroundColor and backgroundHexColor'
       );

  /// Get the effective background color
  Color? get effectiveBackgroundColor {
    if (backgroundColor != null) return backgroundColor;
    if (backgroundHexColor != null) {
      return ModalColors.fromHex(backgroundHexColor!);
    }
    return null;
  }

  /// Get the effective shadow
  BoxShadow get effectiveShadow => shadow ?? BoxShadow(
    color: Colors.black.withOpacity(0.1),
    blurRadius: 10,
    spreadRadius: 0,
    offset: const Offset(0, 2),
  );

  /// Create a copy with some properties replaced
  ModalStyle copyWith({
    Color? backgroundColor,
    String? backgroundHexColor,
    double? cornerRadius,
    bool? blurBackground,
    double? blurIntensity,
    double? backgroundOpacity,
    BoxShadow? shadow,
    double? elevation,
    Border? border,
    Gradient? gradient,
    Color? barrierColor,
    bool? barrierDismissible,
    Duration? animationDuration,
    bool? maintainState,
    bool? useSafeArea,
  }) {
    return ModalStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      backgroundHexColor: backgroundHexColor ?? this.backgroundHexColor,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      blurBackground: blurBackground ?? this.blurBackground,
      blurIntensity: blurIntensity ?? this.blurIntensity,
      backgroundOpacity: backgroundOpacity ?? this.backgroundOpacity,
      shadow: shadow ?? this.shadow,
      elevation: elevation ?? this.elevation,
      border: border ?? this.border,
      gradient: gradient ?? this.gradient,
      barrierColor: barrierColor ?? this.barrierColor,
      barrierDismissible: barrierDismissible ?? this.barrierDismissible,
      animationDuration: animationDuration ?? this.animationDuration,
      maintainState: maintainState ?? this.maintainState,
      useSafeArea: useSafeArea ?? this.useSafeArea,
    );
  }
}

/// Header styling configuration
class ModalHeaderStyle {
  final Color? backgroundColor;
  final String? backgroundHexColor;
  final TextStyle? titleStyle;
  final Color? dividerColor;
  final EdgeInsets? padding;
  final double? height;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showDivider;
  final double? elevation;
  final Border? border;
  final Gradient? gradient;

  const ModalHeaderStyle({
    this.backgroundColor,
    this.backgroundHexColor,
    this.titleStyle,
    this.dividerColor,
    this.padding,
    this.height,
    this.leading,
    this.actions,
    this.showDivider = true,
    this.elevation,
    this.border,
    this.gradient,
  });

  Color? get effectiveBackgroundColor {
    if (backgroundColor != null) return backgroundColor;
    if (backgroundHexColor != null) {
      return ModalColors.fromHex(backgroundHexColor!);
    }
    return null;
  }

  ModalHeaderStyle copyWith({
    Color? backgroundColor,
    String? backgroundHexColor,
    TextStyle? titleStyle,
    Color? dividerColor,
    EdgeInsets? padding,
    double? height,
    Widget? leading,
    List<Widget>? actions,
    bool? showDivider,
    double? elevation,
    Border? border,
    Gradient? gradient,
  }) {
    return ModalHeaderStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      backgroundHexColor: backgroundHexColor ?? this.backgroundHexColor,
      titleStyle: titleStyle ?? this.titleStyle,
      dividerColor: dividerColor ?? this.dividerColor,
      padding: padding ?? this.padding,
      height: height ?? this.height,
      leading: leading ?? this.leading,
      actions: actions ?? this.actions,
      showDivider: showDivider ?? this.showDivider,
      elevation: elevation ?? this.elevation,
      border: border ?? this.border,
      gradient: gradient ?? this.gradient,
    );
  }
}

/// Complete modal configuration
class ModalConfiguration {
  final ModalPresentationStyle presentationStyle;
  final ModalTransitionStyle transitionStyle;
  final List<ModalDetent> detents;
  final bool isDismissible;
  final bool showDragIndicator;
  final bool enableSwipeGesture;
  final SwipeDismissDirection swipeDismissDirection;
  final ModalStyle style;
  final ModalHeaderStyle? headerStyle;
  final bool enableDrag;
  final double? dragStartThreshold;
  
  const ModalConfiguration({
    this.presentationStyle = ModalPresentationStyle.sheet,
    this.transitionStyle = ModalTransitionStyle.automatic,
    this.detents = const [ModalDetent.large],
    this.isDismissible = true,
    this.showDragIndicator = true,
    this.enableSwipeGesture = true,
    this.swipeDismissDirection = SwipeDismissDirection.vertical,
    this.style = const ModalStyle(),
    this.headerStyle,
    this.enableDrag = true,
    this.dragStartThreshold,
  });

  ModalConfiguration copyWith({
    ModalPresentationStyle? presentationStyle,
    ModalTransitionStyle? transitionStyle,
    List<ModalDetent>? detents,
    bool? isDismissible,
    bool? showDragIndicator,
    bool? enableSwipeGesture,
    SwipeDismissDirection? swipeDismissDirection,
    ModalStyle? style,
    ModalHeaderStyle? headerStyle,
    bool? enableDrag,
    double? dragStartThreshold,
  }) {
    return ModalConfiguration(
      presentationStyle: presentationStyle ?? this.presentationStyle,
      transitionStyle: transitionStyle ?? this.transitionStyle,
      detents: detents ?? this.detents,
      isDismissible: isDismissible ?? this.isDismissible,
      showDragIndicator: showDragIndicator ?? this.showDragIndicator,
      enableSwipeGesture: enableSwipeGesture ?? this.enableSwipeGesture,
      swipeDismissDirection: swipeDismissDirection ?? this.swipeDismissDirection,
      style: style ?? this.style,
      headerStyle: headerStyle ?? this.headerStyle,
      enableDrag: enableDrag ?? this.enableDrag,
      dragStartThreshold: dragStartThreshold ?? this.dragStartThreshold,
    );
  }
}