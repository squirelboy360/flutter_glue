import 'package:flutter/material.dart';
import 'package:flutter_native_text_input/flutter_native_text_input.dart';

class NativeTextService {
  /// Creates a native text input with configurable styling
  static Widget createDefaultInput({
    TextEditingController? controller,
    FocusNode? focusNode,
    String? placeholder,
    ValueChanged<String?>? onChanged,
    ValueChanged<String?>? onSubmitted,
    VoidCallback? onEditingComplete,
    double height = 30,
    TextStyle? style,
    BoxDecoration? decoration,
    Color? placeholderColor,
    double? minHeightPadding,
    TextCapitalization? textCapitalization,
    IosOptions? iosOptions,
  }) {
    return SizedBox(
      height: height,
      child: NativeTextInput(
        controller: controller,
        focusNode: focusNode,
        decoration: decoration,
        style: style,
        minHeightPadding: minHeightPadding ?? 4,
        textCapitalization: textCapitalization ?? TextCapitalization.sentences,
        placeholder: placeholder,
        placeholderColor: placeholderColor,
        iosOptions: iosOptions,
        keyboardType: KeyboardType.defaultType,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        onEditingComplete: onEditingComplete,
      ),
    );
  }

  /// Creates a multiline native text input
  static Widget createMultilineInput({
    TextEditingController? controller,
    FocusNode? focusNode,
    String? placeholder,
    ValueChanged<String?>? onChanged,
    ValueChanged<String?>? onSubmitted,
    VoidCallback? onEditingComplete,
    int maxLines = 5,
    double minHeight = 100,
    TextStyle? style,
    BoxDecoration? decoration,
    Color? placeholderColor,
    double? minHeightPadding,
    TextCapitalization? textCapitalization,
    IosOptions? iosOptions,
  }) {
    return SizedBox(
      height: minHeight,
      child: NativeTextInput(
        controller: controller,
        focusNode: focusNode,
        maxLines: maxLines,
        decoration: decoration,
        style: style,
        minHeightPadding: minHeightPadding ?? 8,
        textCapitalization: textCapitalization ?? TextCapitalization.sentences,
        placeholder: placeholder,
        placeholderColor: placeholderColor,
        iosOptions: iosOptions,
        keyboardType: KeyboardType.defaultType,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        onEditingComplete: onEditingComplete,
      ),
    );
  }

  /// Creates a search-optimized native text input
  static Widget createSearchInput({
    TextEditingController? controller,
    FocusNode? focusNode,
    String? placeholder,
    ValueChanged<String?>? onChanged,
    ValueChanged<String?>? onSubmitted,
    VoidCallback? onEditingComplete,
    double height = 40,
    TextStyle? style,
    BoxDecoration? decoration,
    Color? placeholderColor,
    double? minHeightPadding,
    TextCapitalization? textCapitalization,
    IosOptions? iosOptions,
  }) {
    return SizedBox(
      height: height,
      child: NativeTextInput(
        controller: controller,
        focusNode: focusNode,
        decoration: decoration,
        style: style,
        minHeightPadding: minHeightPadding ?? 4,
        textCapitalization: textCapitalization ?? TextCapitalization.none,
        placeholder: placeholder ?? 'Search',
        placeholderColor: placeholderColor,
        iosOptions: iosOptions,
        keyboardType: KeyboardType.defaultType,
        returnKeyType: ReturnKeyType.search,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        onEditingComplete: onEditingComplete,
      ),
    );
  }

  /// Creates a numeric-only native text input
  static Widget createNumericInput({
    TextEditingController? controller,
    FocusNode? focusNode,
    String? placeholder,
    ValueChanged<String?>? onChanged,
    ValueChanged<String?>? onSubmitted,
    VoidCallback? onEditingComplete,
    double height = 30,
    TextStyle? style,
    BoxDecoration? decoration,
    Color? placeholderColor,
    double? minHeightPadding,
    TextCapitalization? textCapitalization,
    IosOptions? iosOptions,
  }) {
    return SizedBox(
      height: height,
      child: NativeTextInput(
        controller: controller,
        focusNode: focusNode,
        decoration: decoration,
        style: style,
        minHeightPadding: minHeightPadding ?? 4,
        textCapitalization: textCapitalization ?? TextCapitalization.none,
        placeholder: placeholder,
        placeholderColor: placeholderColor,
        iosOptions: iosOptions,
        keyboardType: KeyboardType.numberPad,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        onEditingComplete: onEditingComplete,
      ),
    );
  }
}