// lib/core/services/native/triggers/alerts.dart

import 'package:flutter/material.dart';
import 'package:flutter_platform_alert/flutter_platform_alert.dart';

class AlertService {
  /// Shows a native alert dialog
  /// 
  /// [title] - The title of the alert
  /// [message] - The message/content of the alert
  /// [actions] - Optional list of custom actions. If null, shows an OK button
  static Future<Enum> showAlert({
    required String title,
    required String message,
    List<AlertAction>? actions,
  }) async {
    if (actions == null || actions.isEmpty) {
      // Simple alert with OK button
      return await FlutterPlatformAlert.showAlert(
        windowTitle: title,
        text: message,
        alertStyle: AlertButtonStyle.ok,
      );
    } else {
      // Custom alert with provided actions
      return await FlutterPlatformAlert.showCustomAlert(
        windowTitle: title,
        text: message,
        positiveButtonTitle: actions.isNotEmpty ? actions[0].text : null,
        negativeButtonTitle: actions.length >= 2 ? actions[1].text : null,
        neutralButtonTitle: actions.length >= 3 ? actions[2].text : null,
      );
    }
  }

  /// Shows a confirmation dialog with Yes/No buttons
  static Future<bool> showConfirm({
    required String title,
    required String message,
  }) async {
    final result = await FlutterPlatformAlert.showAlert(
      windowTitle: title,
      text: message,
      alertStyle: AlertButtonStyle.yesNo,
    );
    return result == AlertButton.yesButton;
  }
  
  /// Shows an error alert
  static Future<void> showError({
    required String title,
    required String message,
  }) async {
    await FlutterPlatformAlert.showAlert(
      windowTitle: title,
      text: message,
      alertStyle: AlertButtonStyle.ok,
      iconStyle: IconStyle.error,
    );
  }
}

/// Represents a custom alert action
class AlertAction {
  final String text;
  final VoidCallback? onPressed;

  const AlertAction({
    required this.text,
    this.onPressed,
  });
}

/* USAGE EXAMPLES:

1. Simple alert:
```dart
await AlertService.showAlert(
  title: 'Hello',
  message: 'This is a simple alert'
);
```

2. Custom actions:
```dart
final result = await AlertService.showAlert(
  title: 'Custom Alert',
  message: 'Choose an option',
  actions: [
    AlertAction(
      text: 'Save',
      onPressed: () => print('Save pressed'),
    ),
    AlertAction(
      text: 'Cancel',
      onPressed: () => print('Cancel pressed'),
    ),
  ],
);
```

3. Confirmation dialog:
```dart
final confirmed = await AlertService.showConfirm(
  title: 'Confirm',
  message: 'Are you sure?',
);
if (confirmed) {
  // User pressed Yes
}
```

4. Error alert:
```dart
await AlertService.showError(
  title: 'Error',
  message: 'Something went wrong',
);
```
*/