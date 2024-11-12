import 'dart:io';
import 'package:example_app/core/routing/app_router.dart';
import 'package:example_app/core/services/native/utils/constants/modal/modal_configs.dart';
import 'package:example_app/core/services/native/utils/constants/modal/modal_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class ModalService {
  static const _channel = MethodChannel('native_modal_channel');
 static final navigatorKey = GlobalKey<NavigatorState>();

  static late final GoRouter router;
  static Future<String?> showModalWithRoute(ModalConfig modalConfig, {
    required String route,
    required Map<String, String> arguments,
    bool showNativeHeader = true,
    bool showCloseButton = false,
    String? headerTitle,
    ModalConfiguration? configuration,
  }) async {
    if (Platform.isIOS) {
      return _showNativeModal(
        route: route,
        arguments: arguments,
        showNativeHeader: showNativeHeader,
        showCloseButton: showCloseButton,
        headerTitle: headerTitle,
        configuration: configuration,
      );
    } else {
      return _showMaterialModal(
        route: route,
        arguments: arguments,
        showNativeHeader: showNativeHeader,
        showCloseButton: showCloseButton,
        headerTitle: headerTitle,
        configuration: configuration,
      );
    }
  }

  

  static Future<String?> _showNativeModal({
    required String route,
    required Map<String, String> arguments,
    required bool showNativeHeader,
    required bool showCloseButton,
    String? headerTitle,
    ModalConfiguration? configuration,
  }) async {
    try {
      final Map<String, dynamic> modalArgs = {
        'route': route,
        'arguments': arguments,
        'showNativeHeader': showNativeHeader.toString(),
        'showCloseButton': showCloseButton.toString(),
        'headerTitle': headerTitle,
        ...configuration?.toMap() ?? const ModalConfiguration().toMap(),
      };

      final String? modalId = await _channel.invokeMethod('showModal', modalArgs);
      return modalId;
    } catch (e) {
      debugPrint('Error showing native modal: $e');
      return null;
    }
  }

  static Future<String?> _showMaterialModal({
    required String route,
    required Map<String, String> arguments,
    required bool showNativeHeader,
    required bool showCloseButton,
    String? headerTitle,
    ModalConfiguration? configuration,
  }) async {
    final context = AppRouter.navigatorKey.currentContext;
    if (context == null) return null;

    final modalId = 'modal_${DateTime.now().millisecondsSinceEpoch}';
    final config = configuration ?? const ModalConfiguration();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: config.isDismissible,
      backgroundColor: config.backgroundColor,
      enableDrag: config.enableSwipeGesture,
      showDragHandle: config.showDragIndicator,
      useSafeArea: true,
      constraints: config.presentationStyle == ModalPresentationStyle.fullScreen
          ? BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height,
              maxWidth: MediaQuery.of(context).size.width,
            )
          : null,
      builder: (context) => _MaterialModal(
        route: route,
        arguments: arguments,
        showHeader: showNativeHeader,
        headerTitle: headerTitle,
        showCloseButton: showCloseButton,
        configuration: config,
        modalId: modalId,
      ),
    );

    return modalId;
  }
}

class _MaterialModal extends StatelessWidget {
  final String route;
  final Map<String, String> arguments;
  final bool showHeader;
  final String? headerTitle;
  final bool showCloseButton;
  final ModalConfiguration configuration;
  final String modalId;

  const _MaterialModal({
    required this.route,
    required this.arguments,
    required this.showHeader,
    required this.headerTitle,
    required this.showCloseButton,
    required this.configuration,
    required this.modalId,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: configuration.presentationStyle == ModalPresentationStyle.fullScreen ? 1.0 : 0.9,
      minChildSize: configuration.presentationStyle == ModalPresentationStyle.fullScreen ? 1.0 : 0.5,
      maxChildSize: 1.0,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          if (showHeader) _buildHeader(context),
          Expanded(child: _buildContent(context)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: configuration.backgroundColor ?? theme.cardColor,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              headerTitle ?? '',
              style: theme.textTheme.titleLarge,
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

  Widget _buildContent(BuildContext context) {
    final state = GoRouterState(
      AppRouter.router.configuration,
      uri: Uri.parse(route),
      matchedLocation: route,
      path: route,
      fullPath: route,
      pathParameters: const {},
      extra: arguments,
      pageKey: ValueKey(modalId),
    );

    // Find the matching route
    final matchedRoute = AppRouter.router.configuration.routes
        .whereType<GoRoute>()
        .firstWhere(
          (r) => r.path == route,
          orElse: () => throw Exception('No route found for $route'),
        );

    // Use the route's builder if available
    if (matchedRoute.builder != null) {
      return matchedRoute.builder!(context, state);
    }

    throw Exception('Route builder not found for $route');
  }
}