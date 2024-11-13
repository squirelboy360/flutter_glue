import 'package:flutter/material.dart';
import './models/native_tab_config.dart';
import './native_navigation_service.dart';

Future<void> setupTabs() async {
  final tabs = [
    const NativeTabConfig(
      route: '/',
      title: 'Settings',
      icon: Icons.settings,
      selectedIcon: Icons.home,
    ),
    const NativeTabConfig(
      route: '/example',
      title: 'Example',
      icon: Icons.star_outline,
      selectedIcon: Icons.star,
    ),
  ];

  await NativeNavigationService.setupTabs(tabs);
}
