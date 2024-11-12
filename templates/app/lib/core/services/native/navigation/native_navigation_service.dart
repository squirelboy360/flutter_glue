import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'models/native_navigation_config.dart.dart';
import 'models/native_tab_config.dart';

class NativeNavigationService {
  static const _channel = MethodChannel('native_navigation_channel');
  
  static Future<void> setupTabs(List<NativeTabConfig> tabs) async {
    if (!Platform.isIOS) return;
    
    await _channel.invokeMethod('setupTabs', {
      'tabs': tabs.map((t) => t.toMap()).toList(),
    });
  }

  static Future<void> updateNavigation(NativeNavigationConfig config) async {
    if (!Platform.isIOS) return;
    
    await _channel.invokeMethod('updateNavigation', config.toMap());
  }

  static Future<void> updateTheme(ThemeData theme) async {
    if (!Platform.isIOS) return;
    
    await _channel.invokeMethod('updateTheme', {
      'backgroundColor': theme.scaffoldBackgroundColor.value,
      'tintColor': theme.primaryColor.value,
      'titleColor': theme.textTheme.titleLarge?.color?.value,
      'isDark': theme.brightness == Brightness.dark,
      'tabBarBackground': theme.bottomNavigationBarTheme.backgroundColor?.value,
      'tabBarTint': theme.bottomNavigationBarTheme.selectedItemColor?.value,
    });
  }

  // Listen for native button taps
  static void onBarButtonTap(void Function(String buttonId) callback) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onBarButtonTap') {
        final id = call.arguments['id'] as String;
        callback(id);
      }
    });
  }
}