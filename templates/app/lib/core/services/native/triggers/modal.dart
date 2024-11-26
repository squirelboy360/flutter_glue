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
        
        // Generate a unique modal ID
        final modalId = 'modal_${DateTime.now().millisecondsSinceEpoch}';
        debugPrint('[ModalService] Generated modalId: $modalId');
        
        // Calculate detents based on configuration
        List<String> detents;
        if (config.detents.isNotEmpty) {
          detents = config.detents.map((d) => d.name).toList();
        } else if (config.initialDetent != null) {
          detents = [config.initialDetent!.name];
        } else {
          detents = [ModalDetent.medium.name];
        }
      
        final selectedDetent = config.initialDetent?.name ?? detents.first;

        final methodArguments = {
          'route': route,
          'modalId': modalId,
          'arguments': {
            ...arguments,
            'modalId': modalId,
          },
          'showNativeHeader': showNativeHeader,
          'showCloseButton': showCloseButton,
          'headerTitle': headerTitle,
          'presentationStyle': config.presentationStyle.name,
          'transitionStyle': config.transitionStyle?.name ?? ModalTransitionStyle.coverVertical.name,
          'detents': detents,
          'selectedDetentIdentifier': selectedDetent,
          'isDismissible': config.isDismissible,
          'showDragIndicator': config.showDragIndicator,
          'enableSwipeGesture': config.enableSwipeGesture,
          'cornerRadius': config.cornerRadius ?? 12.0,
          if (config.backgroundColor != null)
            'backgroundColor': config.backgroundColor!.value.toRadixString(16),
          if (config.headerStyle != null) 'headerStyle': {
            if (config.headerStyle!.backgroundColor != null)
              'backgroundColor': config.headerStyle!.backgroundColor!.value.toRadixString(16),
            'height': config.headerStyle!.height,
            if (config.headerStyle!.dividerColor != null)
              'dividerColor': config.headerStyle!.dividerColor!.value.toRadixString(16),
            'showDivider': config.headerStyle!.showDivider,
            'elevation': config.headerStyle!.elevation,
          },
        };

        debugPrint('[ModalService] Showing modal with config: $methodArguments');
        await _channel.invokeMethod<void>('showModal', methodArguments);
        debugPrint('Modal shown with ID: $modalId');
        
        return modalId;
      } catch (e) {
        debugPrint("[ModalService] Error showing native modal: $e");
        return null;
      }
    } else {
      return ModalFallback.showModalWithRoute(
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

  /// Updates the configuration of an active modal
  static Future<bool> updateModalConfiguration({
    required String modalId,
    String? presentationStyle,
    String? transitionStyle,
    List<String>? detents,
    String? selectedDetentIdentifier,
    bool? isDismissible,
    bool? showDragIndicator,
    bool? enableSwipeGesture,
    double? cornerRadius,
    Color? backgroundColor,
    bool? showNativeHeader,
    bool? showCloseButton,
    String? headerTitle,
    Map<String, dynamic>? headerStyle,
  }) async {
    debugPrint('[ModalService] Updating configuration for modalId: $modalId');
    
    if (!Platform.isIOS) {
      // Use the fallback implementation for Android
      final List<ModalDetent> modalDetents = [];
      if (detents != null) {
        for (final detent in detents) {
          switch (detent) {
            case 'small':
              modalDetents.add(ModalDetent.small);
              break;
            case 'medium':
              modalDetents.add(ModalDetent.medium);
              break;
            case 'large':
              modalDetents.add(ModalDetent.large);
              break;
          }
        }
      }

      ModalDetent? selectedDetent;
      if (selectedDetentIdentifier != null) {
        switch (selectedDetentIdentifier) {
          case 'small':
            selectedDetent = ModalDetent.small;
            break;
          case 'medium':
            selectedDetent = ModalDetent.medium;
            break;
          case 'large':
            selectedDetent = ModalDetent.large;
            break;
        }
      }

      ModalPresentationStyle modalPresentationStyle = ModalPresentationStyle.sheet;
      if (presentationStyle != null) {
        switch (presentationStyle) {
          case 'fullScreen':
            modalPresentationStyle = ModalPresentationStyle.fullScreen;
            break;
          case 'formSheet':
            modalPresentationStyle = ModalPresentationStyle.formSheet;
            break;
          case 'pageSheet':
            modalPresentationStyle = ModalPresentationStyle.pageSheet;
            break;
        }
      }

      return ModalFallback.updateModalConfiguration(
        modalId,
        ModalConfiguration(
          presentationStyle: modalPresentationStyle,
          detents: modalDetents,
          initialDetent: selectedDetent,
          isDismissible: isDismissible ?? true,
          showDragIndicator: showDragIndicator ?? true,
          enableSwipeGesture: enableSwipeGesture ?? true,
          cornerRadius: cornerRadius,
          backgroundColor: backgroundColor,
          headerStyle: headerStyle != null ? ModalHeaderStyle(
            backgroundColor: headerStyle['backgroundColor'] != null 
              ? Color(headerStyle['backgroundColor'] as int)
              : null,
            height: headerStyle['height'] as double?,
            dividerColor: headerStyle['dividerColor'] != null 
              ? Color(headerStyle['dividerColor'] as int)
              : null,
            showDivider: headerStyle['showDivider'] as bool? ?? true,
            elevation: headerStyle['elevation'] as double?,
          ) : null,
        ),
      );
    }
    
    try {
      final Map<String, dynamic> arguments = {
        'modalId': modalId,
        if (presentationStyle != null) 'presentationStyle': presentationStyle,
        if (transitionStyle != null) 'transitionStyle': transitionStyle,
        if (detents != null) 'detents': detents,
        if (selectedDetentIdentifier != null) 'selectedDetentIdentifier': selectedDetentIdentifier,
        if (isDismissible != null) 'isDismissible': isDismissible,
        if (showDragIndicator != null) 'showDragIndicator': showDragIndicator,
        if (enableSwipeGesture != null) 'enableSwipeGesture': enableSwipeGesture,
        if (cornerRadius != null) 'cornerRadius': cornerRadius,
        if (backgroundColor != null) 'backgroundColor': backgroundColor.value.toRadixString(16),
        if (showNativeHeader != null) 'showNativeHeader': showNativeHeader,
        if (showCloseButton != null) 'showCloseButton': showCloseButton,
        if (headerTitle != null) 'headerTitle': headerTitle,
        if (headerStyle != null) 'headerStyle': headerStyle,
      };

      debugPrint('[ModalService] Calling native updateModalConfiguration with args: $arguments');
      final result = await _channel.invokeMethod<bool>('updateModalConfiguration', arguments);
      debugPrint('[ModalService] Native updateModalConfiguration returned: $result');
      return result ?? false;
    } catch (e) {
      debugPrint('[ModalService] Error updating modal configuration: $e');
      return false;
    }
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

  /// Updates the detent of an active modal
  static Future<bool> updateModalDetent(String modalId, ModalDetent detent) async {
    if (!Platform.isIOS) {
      return ModalFallback.updateModalDetent(modalId, detent);
    }
    
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

  /// Updates the presentation style of an active modal
  static Future<bool> updateModalPresentationStyle(String modalId, ModalPresentationStyle style) async {
    if (!Platform.isIOS) {
      return ModalFallback.updateModalPresentationStyle(modalId, style);
    }
    
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
}
