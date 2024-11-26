import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../text_input_service.dart';

class TextInputController {
  MethodChannel? _channel;
  
  void setChannel(MethodChannel channel) {
    _channel = channel;
  }

  Future<void> hideKeyboard() async {
    await _channel?.invokeMethod('clearFocus');
  }
}

class PlatformTextInput extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onEditingComplete;
  final TextConfig nativeConfig;
  final String? viewId;
  final TextInputController? textInputController;

  const PlatformTextInput({
    super.key,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
    required this.nativeConfig,
    this.viewId,
    this.textInputController,
  });

  @override
  State<PlatformTextInput> createState() => _PlatformTextInputState();
}

class _PlatformTextInputState extends State<PlatformTextInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  MethodChannel? _channel;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void didUpdateWidget(PlatformTextInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.nativeConfig != widget.nativeConfig) {
      _updateNativeStyle();
    }
  }

  void _updateNativeStyle() {
    if (_channel != null) {
      _channel!.invokeMethod('updateStyle', widget.nativeConfig.toNativeParams());
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use native view on supported platforms
    if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android) {
      final creationParams = {
        'initialText': _controller.text,
        ...widget.nativeConfig.toNativeParams(),
        'viewId': widget.viewId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      };

      if (defaultTargetPlatform == TargetPlatform.iOS) {
        return UiKitView(
          viewType: 'com.example.app/native_text_input',
          onPlatformViewCreated: _onPlatformViewCreated,
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
         
        );
      } else {
        return AndroidView(
          viewType: 'com.example.app/native_text_input',
          onPlatformViewCreated: _onPlatformViewCreated,
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
        );
      }
    }

    // Fallback to Flutter TextField for web or other platforms
    return Material(
      color: Colors.transparent,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        decoration: InputDecoration(
          hintText: widget.nativeConfig.placeholder,
          hintStyle: TextStyle(color: widget.nativeConfig.placeholderColor),
          filled: true,
          fillColor: widget.nativeConfig.backgroundColor,
          contentPadding: widget.nativeConfig.padding,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.nativeConfig.cornerRadius ?? 0),
            borderSide: BorderSide(
              color: widget.nativeConfig.borderColor ?? Colors.transparent,
              width: widget.nativeConfig.borderWidth ?? 0,
            ),
          ),
        ),
        style: widget.nativeConfig.textStyle,
        keyboardType: widget.nativeConfig.keyboardType,
        obscureText: widget.nativeConfig.secure ?? false,
        maxLines: widget.nativeConfig.maxLines,
        autocorrect: widget.nativeConfig.autocorrect ?? true,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        onEditingComplete: widget.onEditingComplete,
      ),
    );
  }

  void _onPlatformViewCreated(int id) {
    _channel = MethodChannel('com.example.app/native_text_input_$id');
    widget.textInputController?.setChannel(_channel!);
    _updateNativeStyle();
    
    // Set up method call handlers
    _channel!.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onChanged':
          final String text = call.arguments['text'];
          _controller.text = text;
          widget.onChanged?.call(text);
          break;
        case 'onSubmitted':
          final String text = call.arguments['text'];
          widget.onSubmitted?.call(text);
          break;
        case 'onEditingComplete':
          widget.onEditingComplete?.call();
          break;
      }
    });

    // Set initial text if needed
    if (_controller.text.isNotEmpty) {
      _channel!.invokeMethod('setText', _controller.text);
    }

    // Handle focus changes
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _channel!.invokeMethod('focus');
      } else {
        _channel!.invokeMethod('clearFocus');
      }
    });
  }
}
