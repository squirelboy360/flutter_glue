import 'package:flutter/material.dart';

class NativeTabConfig {
  final String route;
  final String title;
  final IconData icon;
  final IconData? selectedIcon;
  final Map<String, dynamic>? arguments;

  const NativeTabConfig({
    required this.route,
    required this.title,
    required this.icon,
    this.selectedIcon,
    this.arguments,
  });

  Map<String, dynamic> toMap() => {
    'route': route,
    'title': title,
    'icon': _encodeIconData(icon),
    if (selectedIcon != null) 'selectedIcon': _encodeIconData(selectedIcon!),
    if (arguments != null) 'arguments': arguments,
  };

  Map<String, dynamic> _encodeIconData(IconData icon) => {
    'codePoint': icon.codePoint,
    'fontFamily': icon.fontFamily,
    'fontPackage': icon.fontPackage,
    'matchTextDirection': icon.matchTextDirection,
  };
}