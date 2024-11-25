import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        
        // Calculate detents based on configuration
        List<String> detents;
        if (config.detents.isNotEmpty) {
          detents = config.detents.map((d) => d.name).toList();
        } else {
          detents = [config.initialDetent.name];
        }
      
                       
        final selectedDetent = config.initialDetent?.name ?? detents.first;

        final methodArguments = {
          'route': route,
          'arguments': {
            ...arguments,
            'showNativeHeader': showNativeHeader.toString(),
            'showCloseButton': showCloseButton.toString(),
            if (headerTitle != null) 'headerTitle': headerTitle,
          },
          'presentationStyle': config.presentationStyle.name,
          'transitionStyle': config.transitionStyle?.name ?? ModalTransitionStyle.coverVertical.name,
          'detents': detents,
          'selectedDetentIdentifier': selectedDetent,
          'isDismissible': config.isDismissible,
          'showDragIndicator': config.showDragIndicator,
          'enableSwipeGesture': config.enableSwipeGesture,
          'swipeDismissDirection': config.swipeDismissDirection?.name ?? SwipeDismissDirection.down.name,
          if (config.backgroundColor != null)
            'backgroundColor': config.backgroundColor!.value,
          if (config.cornerRadius != null)
            'cornerRadius': config.cornerRadius,
          'headerStyle': config.headerStyle != null ? _headerStyleToMap(config.headerStyle!) : null,
          'onWillDismiss': config.onWillDismiss != null,
          'onDismissed': config.onDismissed != null,
          'onPresented': config.onPresented != null,
        };

        final modalId = await _channel.invokeMethod<String>('showModal', methodArguments);
        
        // Set up callback handlers
        if (modalId != null) {
          _channel.setMethodCallHandler((call) async {
            switch (call.method) {
              case 'onWillDismiss':
                if (config.onWillDismiss != null) {
                  return await config.onWillDismiss!();
                }
                return true;
              case 'onDismissed':
                config.onDismissed?.call();
                break;
              case 'onPresented':
                config.onPresented?.call();
                break;
              case 'onDetentChanged':
                final detent = call.arguments['detent'] as String?;
                if (detent != null) {
                  // Handle detent change if needed
                }
                break;
            }
          });
        }

        return modalId;
      } catch (e) {
        if (kDebugMode) {
          print("Error showing native modal: $e");
        }
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
      if (style.backgroundColor != null)
        'headerBackgroundColor': style.backgroundColor!.value,
      if (style.dividerColor != null)
        'headerDividerColor': style.dividerColor!.value,
      if (style.height != null)
        'headerHeight': style.height,
      'showHeaderDivider': style.showDivider,
    };
  }

  /// Dismiss a specific modal by ID
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

  /// Get list of active modal IDs
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
