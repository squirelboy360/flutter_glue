import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/modal_styles.dart';
import 'package:go_router/go_router.dart';
import 'package:example_app/core/routing/routes.dart';

class ModalFallback {
  static const _modalChannel = MethodChannel('native_modal_channel');
  static final _activeModals = <BuildContext>{};

  /// Track if a modal is currently displayed
  static bool get hasActiveModal => _activeModals.isNotEmpty;

  /// Add modal context to tracking
  static void _trackModal(BuildContext context) {
    _activeModals.add(context);
  }

  /// Remove modal context from tracking
  static void _untrackModal(BuildContext context) {
    _activeModals.remove(context);
  }

  /// Handle back navigation when modal is open
  static Future<bool> handleModalBackPress(BuildContext context) async {
    if (hasActiveModal) {
      await closeModal(context);
      return false; // Prevent app exit
    }
    return true; // Allow normal back navigation
  }

  static Widget _buildHeader(
    BuildContext context, 
    String? headerTitle, 
    bool showCloseButton,
    ModalConfiguration? configuration,
  ) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: configuration?.headerStyle?.backgroundColor ?? theme.appBarTheme.backgroundColor,
        border: Border(
          bottom: BorderSide(
            color: configuration?.headerStyle?.dividerColor ?? theme.dividerColor,
            width: 0.5,
          ),
        ),
      ),
      height: configuration?.headerStyle?.height ?? 56.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              headerTitle ?? '',
              style: theme.textTheme.titleMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (showCloseButton)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
        ],
      ),
    );
  }

  static Widget _buildModalContent(
    BuildContext context,
    String route,
    Map<String, dynamic> arguments,
    ModalConfiguration? configuration,
  ) {
    final location = route.startsWith('/') ? route : '/$route';
    final screenHeight = MediaQuery.of(context).size.height;
    final padding = MediaQuery.of(context).padding;
    final availableHeight = screenHeight - padding.top - padding.bottom;
    
    double modalHeight = _getDetentHeight(
      context, 
      configuration?.initialDetent ?? ModalDetent.large,
      configuration?.customDetentHeight,
    );

    // Ensure the modal height doesn't exceed available space
    modalHeight = modalHeight.clamp(0.0, availableHeight);

    return SizedBox(
      width: double.infinity,
      height: modalHeight,
      child: Navigator(
        onGenerateRoute: (settings) {
          final routeConfig = Routes.getRoute(location);
          if (routeConfig == null) return null;

          return MaterialPageRoute(
            builder: (context) => routeConfig.builder(context, arguments),
            settings: RouteSettings(
              name: location,
              arguments: arguments,
            ),
          );
        },
      ),
    );
  }

  static double _getDetentHeight(BuildContext context, ModalDetent detent, double? customHeight) {
    final screenHeight = MediaQuery.of(context).size.height;
    final padding = MediaQuery.of(context).padding;
    final availableHeight = screenHeight - padding.top - padding.bottom;

    switch (detent) {
      case ModalDetent.large:
        return availableHeight * 0.9;
      case ModalDetent.medium:
        return availableHeight * 0.6;
      case ModalDetent.small:
        return availableHeight * 0.3;
      case ModalDetent.custom:
        return customHeight ?? availableHeight * 0.6;
    }
  }

  static Future<String?> showModal({
    required BuildContext context,
    required String route,
    required Map<String, dynamic> arguments,
    bool showNativeHeader = true,
    bool showCloseButton = true,
    String? headerTitle,
    ModalConfiguration? configuration,
  }) async {
    final modalId = 'flutter_modal_${DateTime.now().millisecondsSinceEpoch}';
    final theme = Theme.of(context);
    
    _trackModal(context);
    
    Future<bool> handleWillDismiss() async {
      if (configuration?.onWillDismiss != null) {
        return await configuration!.onWillDismiss!();
      }
      return true;
    }

    void handleDismissed() {
      _untrackModal(context);
      configuration?.onDismissed?.call();
    }

    if (configuration?.presentationStyle == ModalPresentationStyle.sheet) {
      await showModalBottomSheet(
        context: context,
        isDismissible: configuration?.isDismissible ?? true,
        enableDrag: configuration?.enableSwipeGesture ?? true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black54,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(configuration?.cornerRadius ?? 12),
            topRight: Radius.circular(configuration?.cornerRadius ?? 12),
          ),
        ),
        builder: (context) => WillPopScope(
          onWillPop: () => handleModalBackPress(context),
          child: Theme(
            data: theme,
            child: Container(
              decoration: BoxDecoration(
                color: configuration?.backgroundColor ?? theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(configuration?.cornerRadius ?? 12),
                  topRight: Radius.circular(configuration?.cornerRadius ?? 12),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (configuration?.showDragIndicator ?? true)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      width: 32,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  if (showNativeHeader)
                    _buildHeader(
                      context,
                      headerTitle,
                      showCloseButton,
                      configuration,
                    ),
                  Flexible(
                    child: _buildModalContent(
                      context,
                      route,
                      arguments,
                      configuration,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ).then((_) => handleDismissed());
    } else {
      await showDialog(
        context: context,
        barrierDismissible: configuration?.isDismissible ?? true,
        builder: (context) => WillPopScope(
          onWillPop: () => handleModalBackPress(context),
          child: Theme(
            data: theme,
            child: Dialog(
              backgroundColor: configuration?.backgroundColor ?? theme.scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(configuration?.cornerRadius ?? 0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showNativeHeader)
                    _buildHeader(
                      context,
                      headerTitle,
                      showCloseButton,
                      configuration,
                    ),
                  Flexible(
                    child: _buildModalContent(
                      context,
                      route,
                      arguments,
                      configuration,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ).then((_) => handleDismissed());
    }

    configuration?.onPresented?.call();
    return modalId;
  }

  static Future<void> closeModal(BuildContext context) async {
    if (!hasActiveModal) return;

    try {
      await _modalChannel.invokeMethod('closeModal');
    } catch (e) {
      // Native modal might not exist, continue with Flutter modal closing
    }

    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  static bool shouldHandleBackPress(BuildContext context) {
    return hasActiveModal;
  }
}
