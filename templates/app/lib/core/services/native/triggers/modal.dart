import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'dart:io' show Platform;

import '../../../routing/app_router.dart';
import '../constants/modal_styles.dart';

class ModalService {
  static const _channel = MethodChannel('native_modal_channel');

  /// Shows a modal with the specified route and options
  static Future<String?> showModalWithRoute({
    required String route,
    required Map<String, String> arguments,
    bool showNativeHeader = true,
    bool showCloseButton = true,
    String? headerTitle,
    ModalConfiguration? configuration,
  }) async {
    final config = configuration ?? const ModalConfiguration();

    if (Platform.isIOS) {
      try {
        final methodArguments = {
          'route': route,
          'arguments': {
            ...arguments,
            'showNativeHeader': showNativeHeader.toString(),
            'showCloseButton': showCloseButton.toString(),
            if (headerTitle != null) 'headerTitle': headerTitle,
          },
          'presentationStyle': config.presentationStyle.name,
          'transitionStyle': config.transitionStyle.name,
          'detents': config.detents.map((d) => d.height).toList(),
          'isDismissible': config.isDismissible,
          'showDragIndicator': config.showDragIndicator,
          'enableSwipeGesture': config.enableSwipeGesture,
          'swipeDismissDirection': config.swipeDismissDirection.name,
          if (config.style.effectiveBackgroundColor != null)
            'backgroundColor': config.style.effectiveBackgroundColor!.value,
          if (config.style.cornerRadius != null)
            'cornerRadius': config.style.cornerRadius,
          'blurBackground': config.style.blurBackground,
          'blurIntensity': config.style.blurIntensity,
          'backgroundOpacity': config.style.backgroundOpacity,
          if (config.style.animationDuration != null)
            'animationDuration': config.style.animationDuration!.inMilliseconds,
          if (config.headerStyle != null)
            ..._headerStyleToMap(config.headerStyle!),
        };

        final modalId = await _channel.invokeMethod<String>('showModal', methodArguments);
        return modalId;
      } on PlatformException catch (e) {
        if (kDebugMode) {
          print("Error showing native modal: ${e.message}");
        }
        return null;
      }
    } else {
      final context = navigatorKey.currentContext;
      if (context == null) return null;

      final modalId = 'flutter_modal_${DateTime.now().millisecondsSinceEpoch}';

      // Use GoRouter for navigation to maintain consistency
      await GoRouter.of(context).push(
        route,
        extra: arguments,
      );

      return modalId;
    }
  }

  static Map<String, dynamic> _headerStyleToMap(ModalHeaderStyle style) {
    return {
      if (style.effectiveBackgroundColor != null)
        'headerBackgroundColor': style.effectiveBackgroundColor!.value,
      if (style.height != null) 'headerHeight': style.height,
      if (style.dividerColor != null)
        'headerDividerColor': style.dividerColor!.value,
      'headerShowDivider': style.showDivider,
      if (style.elevation != null) 'headerElevation': style.elevation,
    };
  }

  static Widget _buildRouterContent(
      String route, Map<String, String> arguments) {
    return Builder(
      builder: (context) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.push(route, extra: arguments);
        });
        return const SizedBox.expand();
      },
    );
  }

  static Widget _buildModalContent({
    required BuildContext context,
    required String route,
    required Map<String, String> arguments,
    required bool showHeader,
    required String? headerTitle,
    required bool showCloseButton,
    required ModalConfiguration configuration,
  }) {
    return Material(
      color: configuration.style.effectiveBackgroundColor,
      child: SafeArea(
        child: Column(
          mainAxisSize: configuration.presentationStyle == ModalPresentationStyle.fullScreen 
              ? MainAxisSize.max 
              : MainAxisSize.min,
          children: [
            if (showHeader)
              _buildHeader(
                context,
                headerTitle: headerTitle,
                showCloseButton: showCloseButton,
                headerStyle: configuration.headerStyle,
              ),
            Flexible(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: _buildRouterContent(route, arguments),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _showBottomSheet(
    BuildContext context,
    Widget content,
    ModalConfiguration configuration,
  ) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: configuration.isDismissible,
      enableDrag: configuration.enableSwipeGesture,
      backgroundColor: Colors.transparent,
      barrierColor: configuration.style.barrierColor,
      useSafeArea: true,
      constraints: const BoxConstraints(
        maxHeight: double.infinity,
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: configuration.style.effectiveBackgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(configuration.style.cornerRadius ?? 16.0),
              topRight: Radius.circular(configuration.style.cornerRadius ?? 16.0),
            ),
          ),
          child: content,
        ),
      ),
    );
  }

  static Future<void> _showFullScreenModal(
    BuildContext context,
    Widget content,
    ModalConfiguration configuration,
  ) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        fullscreenDialog: true,
        opaque: !configuration.style.blurBackground,
        barrierColor: configuration.style.barrierColor,
        transitionDuration: configuration.style.animationDuration ??
            const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) => content,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          switch (configuration.transitionStyle) {
            case ModalTransitionStyle.fade:
              return FadeTransition(opacity: animation, child: child);
            case ModalTransitionStyle.zoom:
              return ScaleTransition(scale: animation, child: child);
            case ModalTransitionStyle.horizontal:
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            default:
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 1.0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
          }
        },
      ),
    );
  }

  static Future<void> _showDialogModal(
    BuildContext context,
    Widget content,
    ModalConfiguration configuration,
  ) {
    return showDialog(
      context: context,
      barrierDismissible: configuration.isDismissible,
      barrierColor: configuration.style.barrierColor,
      useSafeArea: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: configuration.style.elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            configuration.style.cornerRadius ?? 16.0,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: configuration.style.effectiveBackgroundColor,
            borderRadius: BorderRadius.circular(
              configuration.style.cornerRadius ?? 16.0,
            ),
          ),
          child: content,
        ),
      ),
    );
  }

  static Widget _buildHeader(
    BuildContext context, {
    String? headerTitle,
    bool showCloseButton = false,
    ModalHeaderStyle? headerStyle,
  }) {
    return Container(
      padding: headerStyle?.padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: headerStyle?.effectiveBackgroundColor,
        border: headerStyle?.border,
        gradient: headerStyle?.gradient,
      ),
      child: Row(
        children: [
          if (headerStyle?.leading != null) headerStyle!.leading!,
          Expanded(
            child: Text(
              headerTitle ?? '',
              style: headerStyle?.titleStyle ??
                  Theme.of(context).textTheme.titleLarge,
            ),
          ),
          if (showCloseButton)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ...?headerStyle?.actions,
        ],
      ),
    );
  }

  static Future<bool> dismissModal(String modalId) async {
    if (Platform.isIOS) {
      try {
        await _channel.invokeMethod('dismissModal', {'modalId': modalId});
      } catch (e) {
        if (kDebugMode) {
          print("Error dismissing modal: $e");
        }
      }
    } else {
      final context = navigatorKey.currentContext;
      if (context != null) {
        context.pop();
      }
    }
    return true;
  }

  static Future<int> dismissAllModals() async {
    if (Platform.isIOS) {
      try {
        final result = await _channel.invokeMethod('dismissAllModals');
        return (result as Map)['dismissedCount'] as int;
      } catch (e) {
        return 0;
      }
    } else {
      final context = navigatorKey.currentContext;
      if (context != null) {
        context.pop();
        return 1;
      }
      return 0;
    }
  }

  static Future<List<String>> getActiveModals() async {
    if (Platform.isIOS) {
      try {
        final List<dynamic> modals =
            await _channel.invokeMethod('getActiveModals');
        return modals.cast<String>();
      } catch (e) {
        return [];
      }
    }
    return [];
  }
}
