import 'package:example_app/core/services/native/constants/modal_styles.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:example_app/core/routing/routes.dart';

class ModalFallback {
  static Widget _buildHeader(BuildContext context, String? headerTitle, bool showCloseButton) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark 
            ? Colors.grey[900] 
            : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: theme.brightness == Brightness.dark 
                ? Colors.grey[800]! 
                : Colors.grey[300]!,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          if (headerTitle != null)
            Expanded(
              child: Text(
                headerTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          if (showCloseButton)
            IconButton(
              icon: Icon(Icons.close, color: theme.iconTheme.color),
              onPressed: () => Navigator.of(context).pop(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
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
    final modalId = 'flutter_modal_${DateTime.now().millisecondsSinceEpoch}';
    final theme = Theme.of(context);
    
    if (configuration?.presentationStyle == ModalPresentationStyle.sheet) {
      await showModalBottomSheet(
        context: context,
        isDismissible: configuration?.isDismissible ?? true,
        enableDrag: configuration?.enableSwipeGesture ?? true,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(configuration?.style.cornerRadius ?? 12)),
        ),
        builder: (context) => Theme(
          data: theme,
          child: FTheme(
            data: theme.brightness == Brightness.dark 
                ? FThemes.zinc.dark 
                : FThemes.zinc.light,
            child: Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(configuration?.style.cornerRadius ?? 12),
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (configuration?.showDragIndicator ?? true)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.brightness == Brightness.dark 
                              ? Colors.grey[800] 
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    if (showNativeHeader) _buildHeader(context, headerTitle, showCloseButton),
                    Flexible(
                      child: Navigator(
                        onGenerateRoute: (_) {
                          final routeConfig = Routes.getRoute(route);
                          if (routeConfig == null) return null;
                          
                          return MaterialPageRoute(
                            builder: (context) => routeConfig.builder(context, arguments),
                            settings: RouteSettings(
                              name: route,
                              arguments: arguments,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      // For non-sheet modals, show a full-screen dialog
      await showDialog(
        context: context,
        barrierDismissible: configuration?.isDismissible ?? true,
        builder: (context) => Theme(
          data: theme,
          child: FTheme(
            data: theme.brightness == Brightness.dark 
                ? FThemes.zinc.dark 
                : FThemes.zinc.light,
            child: Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.zero,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(configuration?.style.cornerRadius ?? 0),
                ),
                child: Column(
                  children: [
                    if (showNativeHeader) _buildHeader(context, headerTitle, showCloseButton),
                    Expanded(
                      child: Navigator(
                        onGenerateRoute: (_) {
                          final routeConfig = Routes.getRoute(route);
                          if (routeConfig == null) return null;
                          
                          return MaterialPageRoute(
                            builder: (context) => routeConfig.builder(context, arguments),
                            settings: RouteSettings(
                              name: route,
                              arguments: arguments,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    
    return modalId;
  }
}
