import 'package:flutter/services.dart';
import 'platform_interface.dart';

class MethodChannelNativeTextInput extends NativeTextInputPlatform {
  static const MethodChannel _channel = MethodChannel('native_text_input');

  @override
  Future<void> initialize() async {
    await _channel.invokeMethod('initialize');
  }

  static Future<void> setText(String viewId, String text) async {
    await _channel.invokeMethod('setText', {
      'viewId': viewId,
      'text': text,
    });
  }

  static Future<String?> getText(String viewId) async {
    return await _channel.invokeMethod('getText', {
      'viewId': viewId,
    });
  }

  static Future<void> setFocus(String viewId, bool focus) async {
    await _channel.invokeMethod('setFocus', {
      'viewId': viewId,
      'focus': focus,
    });
  }
}
