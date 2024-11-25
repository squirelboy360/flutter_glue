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

  static Widget _buildHeader({
    required String? headerTitle,
    required bool showNativeHeader,
    required bool showCloseButton,
    required ModalHeaderStyle? headerStyle,
    required VoidCallback onClose,
  }) {
    if (!showNativeHeader) return const SizedBox.shrink();

    return Container(
      height: headerStyle?.height ?? 56,
      decoration: BoxDecoration(
        color: headerStyle?.backgroundColor ?? Colors.white,
        border: headerStyle?.showDivider == true
            ? Border(
                bottom: BorderSide(
                  color: headerStyle?.dividerColor ?? Colors.grey[300]!,
                  width: 1,
                ),
              )
            : null,
      ),
      child: Stack(
        children: [
          if (headerTitle != null)
            Center(
              child: Text(
                headerTitle,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (showCloseButton)
            Positioned(
              right: 8,
              top: 8,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: onClose,
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
            final screenHeight = MediaQuery.of(context).size.height;
            final modalHeight = screenHeight * currentConfig.initialDetent.height;

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
                    headerTitle: headerTitle,
                    showNativeHeader: showNativeHeader,
                    showCloseButton: showCloseButton,
                    headerStyle: currentConfig.headerStyle,
                    onClose: () => Navigator.of(context).pop(),
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
