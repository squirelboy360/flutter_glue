import 'package:flutter/material.dart';
import 'text_input/platform_text_input.dart';

class TextInputService {
  /// Creates a default single-line text input
  static Widget createDefaultInput({
    TextEditingController? controller,
    FocusNode? focusNode,
    String? placeholder,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    VoidCallback? onEditingComplete,
    double height = 30,
    TextStyle? style,
    Color? placeholderColor,
    TextCapitalization textCapitalization = TextCapitalization.none,
    Map<String, dynamic>? platformConfig,
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
        textCapitalization: textCapitalization,
        platformConfig: platformConfig,
      ),
    );
  }

  /// Creates a multiline text input
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
    Color? placeholderColor,
    TextCapitalization textCapitalization = TextCapitalization.sentences,
    Map<String, dynamic>? platformConfig,
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
        textCapitalization: textCapitalization,
        platformConfig: platformConfig,
      ),
    );
  }

  /// Creates a search-optimized text input
  static Widget createSearchInput({
    TextEditingController? controller,
    FocusNode? focusNode,
    String? placeholder,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    VoidCallback? onEditingComplete,
    double height = 40,
    TextStyle? style,
    Color? placeholderColor,
    Map<String, dynamic>? platformConfig,
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
        platformConfig: platformConfig,
      ),
    );
  }
}
