import 'package:flutter/material.dart';
import '../constants/modal_styles.dart';
import '../../../routing/core/route_handler.dart';

class ModalFallback {
  static Widget _buildDragHandle() {
    return Container(
      width: 32,
      height: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  static double _getModalHeight(BuildContext context, ModalConfiguration currentConfig) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    if (currentConfig.initialDetent != null) {
      return screenHeight * currentConfig.initialDetent!.height;
    }
    
    // Default to medium height if no detent specified
    return screenHeight * ModalDetent.medium.height;
  }

  static Widget _buildHeader(
    BuildContext context, {
    required bool showCloseButton,
    String? headerTitle,
    ModalHeaderStyle? headerStyle,
    required String modalId,
  }) {
    return Container(
      height: headerStyle?.height ?? 56.0,
      decoration: BoxDecoration(
        color: headerStyle?.backgroundColor ?? Theme.of(context).cardColor,
        border: headerStyle?.showDivider == true ? Border(
          bottom: BorderSide(
            color: headerStyle?.dividerColor ?? Colors.grey.shade300,
            width: 1.0,
          ),
        ) : null,
        boxShadow: headerStyle?.elevation != null ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: headerStyle!.elevation!,
            offset: const Offset(0, 1),
          ),
        ] : null,
      ),
      child: Stack(
        children: [
          if (headerTitle != null)
            Center(
              child: Text(
                headerTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (showCloseButton)
            Positioned(
              right: 8,
              top: 0,
              bottom: 0,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
        ],
      ),
    );
  }

  // Map to store modal state controllers
  static final Map<String, _ModalStateController> _modalControllers = {};

  /// Updates the configuration of an active modal
  static Future<bool> updateModalConfiguration(String modalId, ModalConfiguration configuration) async {
    final controller = _modalControllers[modalId];
    if (controller != null) {
      controller.updateConfiguration(configuration);
      return true;
    }
    return false;
  }

  /// Updates the detent of an active modal
  static Future<bool> updateModalDetent(String modalId, ModalDetent detent) async {
    final controller = _modalControllers[modalId];
    if (controller != null) {
      controller.updateDetent(detent);
      return true;
    }
    return false;
  }

  /// Updates the presentation style of an active modal
  static Future<bool> updateModalPresentationStyle(String modalId, ModalPresentationStyle style) async {
    final controller = _modalControllers[modalId];
    if (controller != null) {
      controller.updatePresentationStyle(style);
      return true;
    }
    return false;
  }

  static Future<String?> showModalWithRoute({
    required BuildContext context,
    required String route,
    required Map<String, String> arguments,
    bool showNativeHeader = true,
    bool showCloseButton = true,
    String? headerTitle,
    ModalConfiguration? configuration,
  }) async {
    final config = configuration ?? const ModalConfiguration();
    final modalId = 'modal_${DateTime.now().millisecondsSinceEpoch}';
    
    // Create and store the modal controller
    final controller = _ModalStateController(config, context);
    _modalControllers[modalId] = controller;
    
    try {
      await showModalBottomSheet(
        context: context,
        isDismissible: config.isDismissible,
        enableDrag: config.enableSwipeGesture,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            final currentConfig = controller.configuration;
            final modalHeight = _getModalHeight(context, currentConfig);

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: modalHeight,
              decoration: BoxDecoration(
                color: currentConfig.backgroundColor ?? Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(currentConfig.cornerRadius ?? 12.0),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (currentConfig.showDragIndicator) _buildDragHandle(),
                  if (showNativeHeader) _buildHeader(
                    context,
                    showCloseButton: showCloseButton,
                    headerTitle: headerTitle,
                    headerStyle: currentConfig.headerStyle,
                    modalId: modalId,
                  ),
                  Expanded(
                    child: Navigator(
                      onGenerateRoute: (settings) => MaterialPageRoute(
                        builder: (context) => RouteHandler.buildRoute(route, {
                          ...arguments,
                          'modalId': modalId,
                        }),
                        settings: settings,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
      
      return modalId;
    } catch (e) {
      debugPrint('[ModalFallback] Error showing modal: $e');
      _modalControllers.remove(modalId);
      return null;
    }
  }

  static Future<String?> showModal({
    required BuildContext context,
    required String route,
    required Map<String, String> arguments,
    bool showNativeHeader = true,
    bool showCloseButton = true,
    String? headerTitle,
    ModalConfiguration? configuration,
  }) async {
    final config = configuration ?? const ModalConfiguration();
    final detents = config.detents;
    final initialDetent = detents.length == 1 ? detents.first : config.initialDetent;

    // Create a unique modal ID
    final modalId = 'modal_${DateTime.now().millisecondsSinceEpoch}';

    // Create and store the modal controller
    final controller = _ModalStateController(config, context);
    _modalControllers[modalId] = controller;

    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: config.isDismissible,
      enableDrag: config.enableSwipeGesture,
      isScrollControlled: true,
      builder: (context) {
        return ListenableBuilder(
          listenable: controller,
          builder: (context, child) {
            final currentConfig = controller.configuration;
            final modalHeight = _getModalHeight(context, currentConfig);

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: modalHeight,
              decoration: BoxDecoration(
                color: currentConfig.backgroundColor ?? Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(currentConfig.cornerRadius ?? 10),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (currentConfig.showDragIndicator) _buildDragHandle(),
                  if (showNativeHeader) _buildHeader(
                    context,
                    showCloseButton: showCloseButton,
                    headerTitle: headerTitle,
                    headerStyle: currentConfig.headerStyle,
                    modalId: modalId,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: currentConfig.enableSwipeGesture
                        ? const AlwaysScrollableScrollPhysics()
                        : const NeverScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: modalHeight - (currentConfig.showDragIndicator ? 20 : 0) - (showNativeHeader ? (currentConfig.headerStyle?.height ?? 56) : 0),
                        ),
                        child: RouteHandler.buildRoute(route, {
                          ...arguments,
                          'modalId': modalId,
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    // Clean up the controller
    _modalControllers.remove(modalId);

    return result;
  }
}

class _ModalStateController extends ChangeNotifier {
  ModalConfiguration _configuration;
  final BuildContext context;

  _ModalStateController(this._configuration, this.context);

  ModalConfiguration get configuration => _configuration;

  void updateConfiguration(ModalConfiguration newConfig) {
    // Only update properties that support live updates
    _configuration = _configuration.copyWith(
      presentationStyle: newConfig.presentationStyle,
      detents: newConfig.detents,
      initialDetent: newConfig.initialDetent,
      isDismissible: newConfig.isDismissible,
      showDragIndicator: newConfig.showDragIndicator,
      enableSwipeGesture: newConfig.enableSwipeGesture,
      backgroundColor: newConfig.backgroundColor,
      cornerRadius: newConfig.cornerRadius,
      headerStyle: newConfig.headerStyle,
      // Transition style cannot be updated live
      // transitionStyle: newConfig.transitionStyle,
    );
    notifyListeners();
  }

  void updateDetent(ModalDetent detent) {
    _configuration = _configuration.copyWith(
      detents: [detent],
      initialDetent: detent,
    );
    notifyListeners();
  }

  void updatePresentationStyle(ModalPresentationStyle style) {
    _configuration = _configuration.copyWith(
      presentationStyle: style,
    );
    notifyListeners();
  }
}
