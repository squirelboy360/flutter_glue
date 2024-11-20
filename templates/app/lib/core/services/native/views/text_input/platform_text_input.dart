import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PlatformTextInput extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? placeholder;
  final TextStyle? style;
  final Color? placeholderColor;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onEditingComplete;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final int? maxLines;
  final Map<String, dynamic>? platformConfig;

  const PlatformTextInput({
    Key? key,
    this.controller,
    this.focusNode,
    this.placeholder,
    this.style,
    this.placeholderColor,
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.platformConfig,
  }) : super(key: key);

  @override
  State<PlatformTextInput> createState() => _PlatformTextInputState();
}

class _PlatformTextInputState extends State<PlatformTextInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  late MethodChannel _channel;
  int _viewId = -1;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _focusNode.removeListener(_handleFocusChange);
    _channel.setMethodCallHandler(null);
    super.dispose();
  }

  void _handleFocusChange() {
    if (_viewId != -1) {
      _channel.invokeMethod('focus', {'focus': _focusNode.hasFocus});
    }
  }

  void _onPlatformViewCreated(int viewId) {
    _viewId = viewId;
    _channel = MethodChannel('native_text_input_$viewId');
    _channel.setMethodCallHandler(_handleMethodCall);

    // Initial setup
    _channel.invokeMethod('setText', _controller.text);
    if (_focusNode.hasFocus) {
      _channel.invokeMethod('focus', {'focus': true});
    }
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onTextChanged':
        final text = call.arguments['text'] as String;
        if (text != _controller.text) {
          _controller.text = text;
          widget.onChanged?.call(text);
        }
        break;
      case 'onSubmitted':
        final text = call.arguments['text'] as String;
        widget.onSubmitted?.call(text);
        widget.onEditingComplete?.call();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Platform-specific view parameters
    final Map<String, dynamic> creationParams = {
      'text': _controller.text,
      'placeholder': widget.placeholder,
      'textColor': widget.style?.color?.value,
      'placeholderColor': widget.placeholderColor?.value,
      'fontSize': widget.style?.fontSize,
      'keyboardType': widget.keyboardType.index,
      'textCapitalization': widget.textCapitalization.index,
      'maxLines': widget.maxLines,
      ...?widget.platformConfig,
    };

    // Create the appropriate platform view
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: 'com.example.app/native_text_input',
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'com.example.app/native_text_input',
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
      );
    }

    // Fallback for unsupported platforms
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      decoration: InputDecoration(
        hintText: widget.placeholder,
        hintStyle: TextStyle(color: widget.placeholderColor),
        border: InputBorder.none,
      ),
      style: widget.style,
      keyboardType: widget.keyboardType,
      textCapitalization: widget.textCapitalization,
      maxLines: widget.maxLines,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      onEditingComplete: widget.onEditingComplete,
    );
  }
}
