// lib/src/examples/modal_example.dart





import '../triggers/modal.dart';

/// Example usage of the modal service
class ModalExample {
  /// Shows a basic modal with header and close button
  Future<void> showBasicModal() async {
    await ModalService.showModalWithRoute(
      route: '/example',
      arguments: {'title': 'Basic Modal'},
      showNativeHeader: true,
      showCloseButton: true,
      headerTitle: 'Example',
    );
  }

  /// Shows a modal without native header
  Future<void> showCustomModal() async {
    await ModalService.showModalWithRoute(
      route: '/example',
      arguments: {
        'title': 'Custom Modal',
        'data': 'Some custom data',
      },
      showNativeHeader: false,
    );
  }

  /// Shows multiple modals in sequence
  Future<void> showSequentialModals() async {
    // First modal
    final firstModalId = await ModalService.showModalWithRoute(
      route: '/example',
      arguments: {'title': 'First Modal'},
      headerTitle: 'First',
    );

    // Second modal after delay
    await Future.delayed(const Duration(seconds: 1));
    await ModalService.showModalWithRoute(
      route: '/example',
      arguments: {'title': 'Second Modal'},
      headerTitle: 'Second',
    );

    // Dismiss first modal after some time
    await Future.delayed(const Duration(seconds: 3));
    if (firstModalId != null) {
      await ModalService.dismissModal(firstModalId);
    }
  }
}