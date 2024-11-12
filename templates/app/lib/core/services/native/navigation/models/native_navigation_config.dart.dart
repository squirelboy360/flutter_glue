import 'dart:ui';

class NativeNavigationConfig {
  final String title;
  final List<NativeBarButton>? rightButtons;
  final List<NativeBarButton>? leftButtons;
  final NativeNavigationStyle style;

  const NativeNavigationConfig({
    required this.title,
    this.rightButtons,
    this.leftButtons,
    this.style = const NativeNavigationStyle(),
  });

  Map<String, dynamic> toMap() => {
    'title': title,
    'rightButtons': rightButtons?.map((b) => b.toMap()).toList(),
    'leftButtons': leftButtons?.map((b) => b.toMap()).toList(),
    'style': style.toMap(),
  };
}

class NativeBarButton {
  final String id;
  final String? title;
  final String? systemName;
  final bool isEnabled;

  const NativeBarButton({
    required this.id,
    this.title,
    this.systemName,
    this.isEnabled = true,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'systemName': systemName,
    'isEnabled': isEnabled,
  };
}

class NativeNavigationStyle {
  final Color? backgroundColor;
  final Color? tintColor;
  final Color? titleColor;
  final bool isDark;
  final bool isTranslucent;
  final Color? shadowColor;

  const NativeNavigationStyle({
    this.backgroundColor,
    this.tintColor,
    this.titleColor,
    this.isDark = false,
    this.isTranslucent = true,
    this.shadowColor,
  });

  Map<String, dynamic> toMap() => {
    if (backgroundColor != null) 'backgroundColor': backgroundColor!.value,
    if (tintColor != null) 'tintColor': tintColor!.value,
    if (titleColor != null) 'titleColor': titleColor!.value,
    'isDark': isDark,
    'isTranslucent': isTranslucent,
    if (shadowColor != null) 'shadowColor': shadowColor!.value,
  };
}
