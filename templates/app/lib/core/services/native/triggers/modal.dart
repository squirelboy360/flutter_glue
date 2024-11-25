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
        
        // Generate a unique modal ID that will be used for updates
        final modalId = 'modal_${DateTime.now().millisecondsSinceEpoch}';
        
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
            'modalId': modalId, // Pass modalId in arguments
            'showNativeHeader': showNativeHeader.toString(),
            'showCloseButton': showCloseButton.toString(),
            if (headerTitle != null) 'headerTitle': headerTitle,
          },
          'modalId': modalId, // Also pass at top level for native side
          'presentationStyle': config.presentationStyle.name,
          'transitionStyle': config.transitionStyle?.name ?? ModalTransitionStyle.coverVertical.name,
          'detents': detents,
          'selectedDetentIdentifier': selectedDetent,
          'isDismissible': config.isDismissible,
          'showDragIndicator': config.showDragIndicator,
          'enableSwipeGesture': config.enableSwipeGesture,
          if (config.backgroundColor != null)
            'backgroundColor': config.backgroundColor!.value,
          if (config.cornerRadius != null)
            'cornerRadius': config.cornerRadius,
          'headerStyle': config.headerStyle != null ? _headerStyleToMap(config.headerStyle!) : null,
        };

        // Show modal and get the modalId back from native side
        final result = await _channel.invokeMethod<String>('showModal', methodArguments);
        
        // Return the modalId for future updates
        return result ?? modalId;
      } catch (e) {
        debugPrint("Error showing native modal: $e");
        // Fall back to Flutter implementation
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

  /// Updates the configuration of an active modal
  static Future<bool> updateModalConfiguration(String modalId, ModalConfiguration configuration) async {
    debugPrint('Updating modal configuration for ID: $modalId');
    if (Platform.isIOS) {
      try {
        final methodArguments = {
          'modalId': modalId,
          'presentationStyle': configuration.presentationStyle.name,
          'detents': configuration.detents.map((d) => d.name).toList(),
          'selectedDetentIdentifier': configuration.initialDetent?.name,
          'isDismissible': configuration.isDismissible,
          'showDragIndicator': configuration.showDragIndicator,
          'enableSwipeGesture': configuration.enableSwipeGesture,
          if (configuration.backgroundColor != null)
            'backgroundColor': configuration.backgroundColor!.value,
          if (configuration.cornerRadius != null)
            'cornerRadius': configuration.cornerRadius,
          'headerStyle': configuration.headerStyle != null ? _headerStyleToMap(configuration.headerStyle!) : null,
        };

        final result = await _channel.invokeMethod<bool>('updateModalConfiguration', methodArguments);
        return result ?? false;
      } catch (e) {
        debugPrint("Error updating native modal: $e");
        return false;
      }
    } else {
      return ModalFallback.updateModalConfiguration(modalId, configuration);
    }
  }

  /// Updates the detent of an active modal
  static Future<bool> updateModalDetent(String modalId, ModalDetent detent) async {
    if (Platform.isIOS) {
      try {
        final success = await _channel.invokeMethod<bool>('updateModalDetent', {
          'modalId': modalId,
          'detent': detent.name,
        }) ?? false;
        return success;
      } catch (e) {
        debugPrint("Error updating modal detent: $e");
        return false;
      }
    }
    return false;
  }

  /// Updates the presentation style of an active modal
  static Future<bool> updateModalPresentationStyle(String modalId, ModalPresentationStyle style) async {
    if (Platform.isIOS) {
      try {
        final success = await _channel.invokeMethod<bool>('updateModalPresentationStyle', {
          'modalId': modalId,
          'presentationStyle': style.name,
        }) ?? false;
        return success;
      } catch (e) {
        debugPrint("Error updating modal presentation style: $e");
        return false;
      }
    }
    return false;
  }
}
