import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;

import '../constants/modal_styles.dart';
import '../fallbacks/modal_fallback.dart';

class ModalService {
  static const _channel = MethodChannel('native_modal_channel');

  /// Shows a modal with the specified route and options
  static Future<String?> showModalWithRoute({
    required BuildContext context,
    required String route,
    required Map<String, String> arguments,
    bool showNativeHeader = true,
    bool showCloseButton = true,
    String? headerTitle,
    ModalConfiguration? configuration,
  }) async {
    if (Platform.isIOS) {
      try {
        final config = configuration ?? const ModalConfiguration();

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

        return await _channel.invokeMethod<String>('showModal', methodArguments);
      } catch (e) {
        if (kDebugMode) {
          print("Error showing native modal: $e");
        }
        return null;
      }
    } else {
      return ModalFallback.showModal(
        context: context,
        route: route,
        arguments: arguments,
        showNativeHeader: showNativeHeader,
        showCloseButton: showCloseButton,
        headerTitle: headerTitle,
        configuration: configuration,
      );
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

  static Future<bool> dismissModal(String modalId) async {
    if (Platform.isIOS) {
      try {
        await _channel.invokeMethod('dismissModal', {'modalId': modalId});
        return true;
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  static Future<List<String>> getActiveModals() async {
    if (Platform.isIOS) {
      try {
        final List<dynamic> modals = await _channel.invokeMethod('getActiveModals');
        return modals.cast<String>();
      } catch (e) {
        return [];
      }
    }
    return [];
  }
}
