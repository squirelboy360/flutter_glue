import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NativeTextInput extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? placeholder;
  final TextStyle? style;
  final BoxDecoration? decoration;
  final Color? placeholderColor;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final TextAlign textAlign;
  final int? maxLines;
  final double? minHeight;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Map<String, dynamic>? platformOptions;

  const NativeTextInput({
    super.key,
    this.controller,
    this.focusNode,
    this.placeholder,
    this.style,
    this.decoration,
    this.placeholderColor,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.left,
    this.maxLines,
    this.minHeight,
    this.onEditingComplete,
    this.onChanged,
    this.onSubmitted,
    this.platformOptions,
  });

  @override
  State<NativeTextInput> createState() => _NativeTextInputState();
}

class _NativeTextInputState extends State<NativeTextInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  MethodChannel? _channel;

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
    super.dispose();
  }

  void _handleFocusChange() {
    _channel?.invokeMethod('setFocus', _focusNode.hasFocus);
  }

  Map<String, dynamic> _createCreationParams() {
    return {
      'placeholder': widget.placeholder,
      'placeholderColor': widget.placeholderColor?.value,
      'textColor': widget.style?.color?.value,
      'fontSize': widget.style?.fontSize,
      'maxLines': widget.maxLines,
      'keyboardType': _getKeyboardType(),
      'textAlignment': _getTextAlignment(),
      ...?widget.platformOptions,
    };
  }

  String _getKeyboardType() {
    switch (widget.keyboardType) {
      case TextInputType.number:
        return 'number';
      case TextInputType.emailAddress:
        return 'email';
      case TextInputType.phone:
        return 'phone';
      case TextInputType.url:
        return 'url';
      default:
        return 'text';
    }
  }

  String _getTextAlignment() {
    switch (widget.textAlign) {
      case TextAlign.center:
        return 'center';
      case TextAlign.right:
        return 'right';
      default:
        return 'left';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: 'native_text_input',
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParams: _createCreationParams(),
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'native_text_input',
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParams: _createCreationParams(),
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
    
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      decoration: InputDecoration(
        hintText: widget.placeholder,
        hintStyle: TextStyle(color: widget.placeholderColor),
      ),
      style: widget.style,
      textAlign: widget.textAlign,
      keyboardType: widget.keyboardType,
      textCapitalization: widget.textCapitalization,
      maxLines: widget.maxLines,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      onEditingComplete: widget.onEditingComplete,
    );
  }

  void _onPlatformViewCreated(int id) {
    _channel = MethodChannel('native_text_input_$id');
    _channel!.setMethodCallHandler(_handleMethodCall);

    // Set initial text if controller has text
    if (_controller.text.isNotEmpty) {
      _channel!.invokeMethod('setText', _controller.text);
    }
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onTextChanged':
        final String text = call.arguments as String;
        if (_controller.text != text) {
          _controller.text = text;
        }
        widget.onChanged?.call(text);
        break;
      case 'onSubmitted':
        final String text = call.arguments as String;
        widget.onSubmitted?.call(text);
        break;
      case 'onEditingComplete':
        widget.onEditingComplete?.call();
        break;
    }
  }
}
