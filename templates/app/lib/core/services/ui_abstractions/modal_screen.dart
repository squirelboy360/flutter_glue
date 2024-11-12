import 'package:example_app/core/services/native/navigation/models/native_navigation_config.dart.dart';
import 'package:example_app/core/services/native/triggers/modal.dart';
import 'package:example_app/core/services/native/utils/constants/modal/modal_configs.dart';
import 'package:example_app/core/services/native/utils/constants/modal/modal_styles.dart';
import 'package:example_app/core/services/ui_abstractions/screen.dart';
import 'package:flutter/material.dart';


class ModalScreen extends StatelessWidget {
  final Widget child;
  final String? title;
  final VoidCallback? onClose;
  final Color? backgroundColor;

  const ModalScreen({
    super.key,
    required this.child,
    this.title,
    this.onClose,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return NativeScreen(
      title: title ?? '',
      rightButtons: onClose != null
          ? [
              const NativeBarButton(
                id: 'close',
                systemName: 'xmark',
              ),
            ]
          : null,
      style: NativeNavigationStyle(
        backgroundColor: backgroundColor,
      ),
      child: child,
    );
  }
}

// Extension method for easy modal presentation
extension BuildContextModal on BuildContext {
  Future<T?> showAppModal<T>({
    required String route,
    Map<String, String> arguments = const {},
    String? title,
    bool isDismissible = true,
    Color? backgroundColor,
    List<String> detents = const ['large'],
  }) async {
    final modalId = await ModalService.showModalWithRoute(
      const ModalConfig(), // Add the required ModalConfig argument here
      route: route,
      showCloseButton: true,
      showNativeHeader: true,
      arguments: arguments,
      configuration: ModalConfiguration(
        isDismissible: isDismissible,
        showDragIndicator: true,
        detents: detents,
        presentationStyle: ModalPresentationStyle.formSheet,
      ),
    );
    if (modalId != null) {
      ModalService.router.push(route, extra: arguments);
    }
    return modalId as T?;
  }
}
