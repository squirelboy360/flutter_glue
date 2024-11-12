import 'dart:ui';


import 'modal_styles.dart';



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
  final Duration? animationDuration;
  final bool maintainState;
  final bool useSafeArea;
  final bool enableDrag;
  final double? dragStartThreshold;
  final bool barrierDismissible;
  final Color? barrierColor;
  
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
    this.animationDuration,
    this.maintainState = true,
    this.useSafeArea = true,
    this.enableDrag = true,
    this.dragStartThreshold,
    this.barrierDismissible = true,
    this.barrierColor,
  });

  /// Create a copy with some properties replaced
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
    Duration? animationDuration,
    bool? maintainState,
    bool? useSafeArea,
    bool? enableDrag,
    double? dragStartThreshold,
    bool? barrierDismissible,
    Color? barrierColor,
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
      animationDuration: animationDuration ?? this.animationDuration,
      maintainState: maintainState ?? this.maintainState,
      useSafeArea: useSafeArea ?? this.useSafeArea,
      enableDrag: enableDrag ?? this.enableDrag,
      dragStartThreshold: dragStartThreshold ?? this.dragStartThreshold,
      barrierDismissible: barrierDismissible ?? this.barrierDismissible,
      barrierColor: barrierColor ?? this.barrierColor,
    );
  }
}