import 'package:example_app/core/services/native/views/text_input/method_channel.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class NativeTextInputPlatform extends PlatformInterface {
  NativeTextInputPlatform() : super(token: _token);

  static final Object _token = Object();
  static NativeTextInputPlatform _instance = MethodChannelNativeTextInput();

  static NativeTextInputPlatform get instance => _instance;

  static set instance(NativeTextInputPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  Future<void> initialize() {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  Widget buildView({
    required TextEditingController controller,
    FocusNode? focusNode,
    String? placeholder,
    TextStyle? style,
    BoxDecoration? decoration,
    Color? placeholderColor,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    int? maxLines,
    double? minHeight,
    VoidCallback? onEditingComplete,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    Map<String, dynamic>? platformOptions,
  }) {
    throw UnimplementedError('buildView() has not been implemented.');
  }
}
