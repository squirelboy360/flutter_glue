import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import './models/native_tab_config.dart';
import './native_navigation_service.dart';

Future<void> setupTabs() async {
  final tabs = [
    const NativeTabConfig(
      route: '/example',
      title: 'Example 1',
      icon: CupertinoIcons.home,
      selectedIcon: CupertinoIcons.home,
    ),
    const NativeTabConfig(
      route: '/example',
      title: 'Example 2',
      icon: Icons.star_outline,
      selectedIcon: Icons.star,
    ),
    const NativeTabConfig(
      route: '/example',
      title: 'Example 3',
      icon: CupertinoIcons.globe,
      selectedIcon:CupertinoIcons.globe,
    ),
  ];

  await NativeNavigationService.setupTabs(tabs);
}
