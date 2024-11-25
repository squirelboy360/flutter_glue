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
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: config.isDismissible,
      enableDrag: config.enableSwipeGesture,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * initialDetent.height,
      ),
      builder: (context) {
        final screenHeight = MediaQuery.of(context).size.height;
        final modalHeight = screenHeight * initialDetent.height;
        
        return Container(
          height: modalHeight,
          decoration: BoxDecoration(
            color: config.backgroundColor ?? Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(config.cornerRadius ?? 10),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (config.showDragIndicator) _buildDragHandle(),
              _buildHeader(
                headerTitle: headerTitle,
                showNativeHeader: showNativeHeader,
                showCloseButton: showCloseButton,
                headerStyle: config.headerStyle,
                onClose: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: modalHeight - (config.showDragIndicator ? 20 : 0) - (showNativeHeader ? (config.headerStyle?.height ?? 56) : 0),
                    ),
                    child: RouteHandler.buildRoute(route, arguments),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
