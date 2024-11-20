import 'package:flutter/material.dart';
import 'text_input/platform_text_input.dart';

class NativeTextService {
  /// Creates a native text input with configurable styling
  static Widget createDefaultInput({
    TextEditingController? controller,
    FocusNode? focusNode,
    String? placeholder,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    VoidCallback? onEditingComplete,
    double height = 30,
    TextStyle? style,
    BoxDecoration? decoration,
    Color? placeholderColor,
    TextCapitalization? textCapitalization,
    Map<String, dynamic>? platformOptions,
  }) {
    return SizedBox(
      height: height,
      child: PlatformTextInput(
        controller: controller,
        focusNode: focusNode,
        placeholder: placeholder,
        style: style,
        placeholderColor: placeholderColor,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        onEditingComplete: onEditingComplete,
        textCapitalization: textCapitalization ?? TextCapitalization.none,
        platformConfig: platformOptions,
      ),
    );
  }

  /// Creates a multiline native text input
  static Widget createMultilineInput({
    TextEditingController? controller,
    FocusNode? focusNode,
    String? placeholder,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    VoidCallback? onEditingComplete,
    int maxLines = 5,
    double minHeight = 100,
    TextStyle? style,
    BoxDecoration? decoration,
    Color? placeholderColor,
    TextCapitalization? textCapitalization,
    Map<String, dynamic>? platformOptions,
  }) {
    return SizedBox(
      height: minHeight,
      child: PlatformTextInput(
        controller: controller,
        focusNode: focusNode,
        placeholder: placeholder,
        style: style,
        placeholderColor: placeholderColor,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        onEditingComplete: onEditingComplete,
        maxLines: maxLines,
        textCapitalization: textCapitalization ?? TextCapitalization.sentences,
        platformConfig: platformOptions,
      ),
    );
  }

  /// Creates a search-optimized native text input
  static Widget createSearchInput({
    TextEditingController? controller,
    FocusNode? focusNode,
    String? placeholder,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    VoidCallback? onEditingComplete,
    double height = 40,
    TextStyle? style,
    BoxDecoration? decoration,
    Color? placeholderColor,
    TextCapitalization? textCapitalization,
    Map<String, dynamic>? platformOptions,
  }) {
    return SizedBox(
      height: height,
      child: PlatformTextInput(
        controller: controller,
        focusNode: focusNode,
        placeholder: placeholder ?? 'Search',
        style: style,
        placeholderColor: placeholderColor,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        onEditingComplete: onEditingComplete,
        keyboardType: TextInputType.text,
        textCapitalization: TextCapitalization.none,
        platformConfig: platformOptions,
      ),
    );
  }
}
