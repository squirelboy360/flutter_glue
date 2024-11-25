import 'package:example_app/core/services/native/constants/modal_styles.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart' as F; // Import FThemes

class ModalFallback {
  static Future<String?> showModal({
    required BuildContext context,
    required String route,
    required Map<String, String> arguments,
    bool showNativeHeader = true,
    bool showCloseButton = true,
    String? headerTitle,
    ModalConfiguration? configuration,
  }) async {
    final modalId = 'flutter_modal_${DateTime.now().millisecondsSinceEpoch}';
    
    if (configuration?.presentationStyle == ModalPresentationStyle.sheet) {
      await showModalBottomSheet(
        context: context,
        isDismissible: configuration?.isDismissible ?? true,
        enableDrag: configuration?.enableSwipeGesture ?? true,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          final theme = Theme.of(context);
          return Theme(
            data: theme,
            child: FTheme(
              data: theme.brightness == F.Brightness.dark 
                  ? FThemes.zinc.dark 
                  : FThemes.zinc.light,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showNativeHeader) _buildHeader(context, headerTitle, showCloseButton),
                  Expanded(
                    child: Navigator(
                      onGenerateRoute: (_) => MaterialPageRoute(
                        builder: (_) => Container(), // Placeholder
                        settings: RouteSettings(
                          name: route,
                          arguments: arguments,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      // For non-sheet modals, just push once
      await context.push(
        route,
        extra: {
          ...arguments,
          'showNativeHeader': showNativeHeader.toString(),
          'showCloseButton': showCloseButton.toString(),
          if (headerTitle != null) 'headerTitle': headerTitle,
        },
      );
    }
    
    return modalId;
  }

  static Widget _buildHeader(BuildContext context, String? headerTitle, bool showCloseButton) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              headerTitle ?? '',
              style: Theme.of(context).textTheme.titleLarge,
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
}
