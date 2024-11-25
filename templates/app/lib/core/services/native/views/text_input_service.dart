import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'text_input/platform_text_input.dart';

/// Core configuration for text input
class TextConfig {
  final String? placeholder;
  final TextStyle? textStyle;
  final Color? placeholderColor;
  final TextInputType? keyboardType;
  final bool? autocorrect;
  final bool? secure;
  final int? maxLines;
  final double? cornerRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderWidth;
  final EdgeInsets? padding;
  final Map<String, dynamic>? platformSpecific;

  const TextConfig({
    this.placeholder,
    this.textStyle,
    this.placeholderColor,
    this.keyboardType,
    this.autocorrect,
    this.secure,
    this.maxLines,
    this.cornerRadius,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.padding,
    this.platformSpecific,
  });

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is TextConfig &&
        other.placeholder == placeholder &&
        other.textStyle == textStyle &&
        other.placeholderColor == placeholderColor &&
        other.keyboardType == keyboardType &&
        other.autocorrect == autocorrect &&
        other.secure == secure &&
        other.maxLines == maxLines &&
        other.cornerRadius == cornerRadius &&
        other.backgroundColor == backgroundColor &&
        other.borderColor == borderColor &&
        other.borderWidth == borderWidth &&
        other.padding == padding;

  @override
  int get hashCode => Object.hash(
        placeholder,
        textStyle,
        placeholderColor,
        keyboardType,
        autocorrect,
        secure,
        maxLines,
        cornerRadius,
        backgroundColor,
        borderColor,
        borderWidth,
        padding,
      );

  Map<String, dynamic> toNativeParams() {
    String? getKeyboardType() {
      if (keyboardType == null) return null;
      
      // Handle TextInputType.numberWithOptions()
      if (keyboardType is TextInputType && keyboardType.runtimeType.toString().contains('numberWithOptions')) {
        return 'TextInputType.number';
      }
      
      switch (keyboardType) {
        case TextInputType.number:
          return 'TextInputType.number';
        case TextInputType.phone:
          return 'TextInputType.phone';
        case TextInputType.emailAddress:
          return 'TextInputType.emailAddress';
        case TextInputType.url:
          return 'TextInputType.url';
        case TextInputType.visiblePassword:
          return 'TextInputType.visiblePassword';
        case TextInputType.name:
          return 'TextInputType.name';
        case TextInputType.streetAddress:
          return 'TextInputType.streetAddress';
        case TextInputType.none:
          return 'TextInputType.none';
        default:
          return 'TextInputType.text';
      }
    }

    return {
      if (placeholder != null) 'placeholder': placeholder,
      if (textStyle != null) 'textStyle': {
        'color': textStyle?.color?.value,
        'fontSize': textStyle?.fontSize,
        'fontWeight': textStyle?.fontWeight?.index,
      },
      if (placeholderColor != null) 'placeholderColor': placeholderColor?.value,
      if (keyboardType != null) 'keyboardType': getKeyboardType(),
      if (autocorrect != null) 'autocorrect': autocorrect,
      if (secure != null) 'secure': secure,
      if (maxLines != null) 'maxLines': maxLines,
      if (cornerRadius != null) 'cornerRadius': cornerRadius,
      if (backgroundColor != null) 'backgroundColor': backgroundColor?.value,
      if (borderColor != null) 'borderColor': borderColor?.value,
      if (borderWidth != null) 'borderWidth': borderWidth,
      if (padding != null) 'padding': {
        'left': padding?.left,
        'top': padding?.top,
        'right': padding?.right,
        'bottom': padding?.bottom,
      },
      if (platformSpecific != null) ...platformSpecific!,
    };
  }

  TextConfig copyWith({
    String? placeholder,
    TextStyle? textStyle,
    Color? placeholderColor,
    TextInputType? keyboardType,
    bool? autocorrect,
    bool? secure,
    int? maxLines,
    double? cornerRadius,
    Color? backgroundColor,
    Color? borderColor,
    double? borderWidth,
    EdgeInsets? padding,
    Map<String, dynamic>? platformSpecific,
  }) {
    return TextConfig(
      placeholder: placeholder ?? this.placeholder,
      textStyle: textStyle ?? this.textStyle,
      placeholderColor: placeholderColor ?? this.placeholderColor,
      keyboardType: keyboardType ?? this.keyboardType,
      autocorrect: autocorrect ?? this.autocorrect,
      secure: secure ?? this.secure,
      maxLines: maxLines ?? this.maxLines,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      padding: padding ?? this.padding,
      platformSpecific: platformSpecific ?? this.platformSpecific,
    );
  }

  TextConfig merge(TextConfig? other) {
    if (other == null) return this;
    return copyWith(
      placeholder: other.placeholder,
      textStyle: other.textStyle,
      placeholderColor: other.placeholderColor,
      keyboardType: other.keyboardType,
      autocorrect: other.autocorrect,
      secure: other.secure,
      maxLines: other.maxLines,
      cornerRadius: other.cornerRadius,
      backgroundColor: other.backgroundColor,
      borderColor: other.borderColor,
      borderWidth: other.borderWidth,
      padding: other.padding,
      platformSpecific: other.platformSpecific,
    );
  }
}

class FormFieldConfig extends TextConfig {
  final String? label;
  final String? errorText;
  final bool? required;
  final TextInputAction? textInputAction;
  final bool? enabled;
  final String? helperText;
  final int? maxLength;
  final bool? readOnly;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  
  const FormFieldConfig({
    this.label,
    this.errorText,
    this.required,
    this.textInputAction,
    this.enabled,
    this.helperText,
    this.maxLength,
    this.readOnly,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    super.placeholder,
    super.textStyle,
    super.placeholderColor,
    super.keyboardType,
    super.autocorrect,
    super.secure,
    super.maxLines,
    super.cornerRadius,
    super.backgroundColor,
    super.borderColor,
    super.borderWidth,
    super.padding,
    super.platformSpecific,
  });

  @override
  Map<String, dynamic> toNativeParams() {
    return {
      ...super.toNativeParams(),
      if (label != null) 'label': label,
      if (errorText != null) 'errorText': errorText,
      if (required != null) 'required': required,
      if (textInputAction != null) 'returnKeyType': _getReturnKeyType(textInputAction!),
      if (enabled != null) 'enabled': enabled,
      if (helperText != null) 'helperText': helperText,
      if (maxLength != null) 'maxLength': maxLength,
      if (readOnly != null) 'readOnly': readOnly,
      'textCapitalization': _getTextCapitalization(textCapitalization),
    };
  }

  String _getReturnKeyType(TextInputAction action) {
    switch (action) {
      case TextInputAction.done:
        return 'done';
      case TextInputAction.go:
        return 'go';
      case TextInputAction.next:
        return 'next';
      case TextInputAction.search:
        return 'search';
      case TextInputAction.send:
        return 'send';
      default:
        return 'default';
    }
  }

  String _getTextCapitalization(TextCapitalization cap) {
    switch (cap) {
      case TextCapitalization.words:
        return 'words';
      case TextCapitalization.sentences:
        return 'sentences';
      case TextCapitalization.characters:
        return 'characters';
      default:
        return 'none';
    }
  }
}

class TextInputService {
  static Widget createInput({
    TextEditingController? controller,
    FocusNode? focusNode,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    VoidCallback? onEditingComplete,
    double? height,
    TextConfig? config,
    String? viewId,
    TextInputController? textInputController,
  }) {
    return _wrapWithKeyboardDismissal(
      SizedBox(
        height: height,
        child: PlatformTextInput(
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          onEditingComplete: onEditingComplete,
          nativeConfig: config ?? const TextConfig(),
          viewId: viewId,
          textInputController: textInputController,
        ),
      ),
    );
  }

  static Widget createSearchInput({
    TextEditingController? controller,
    FocusNode? focusNode,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    VoidCallback? onEditingComplete,
    double height = 40,
    TextConfig? config,
    String? viewId,
    BuildContext? context,
  }) {
    final theme = context != null ? Theme.of(context) : null;
    final defaultConfig = TextConfig(
      placeholder: 'Search',
      keyboardType: TextInputType.text,
      autocorrect: false,
      cornerRadius: 12,
      backgroundColor: theme?.colorScheme.surface,
      borderColor: theme?.colorScheme.outline,
      borderWidth: 1,
      padding: const EdgeInsets.symmetric(horizontal: 16),
    );
    
    return createInput(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onEditingComplete: onEditingComplete,
      height: height,
      viewId: viewId,
      config: config != null ? defaultConfig.merge(config) : defaultConfig,
    );
  }

  static Widget _wrapWithKeyboardDismissal(Widget child) {
    return Builder(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: child,
      ),
    );
  }
}
