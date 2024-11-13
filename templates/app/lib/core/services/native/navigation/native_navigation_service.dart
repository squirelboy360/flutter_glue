import 'dart:io';
import 'dart:ui' as ui;
import 'package:example_app/core/services/native/navigation/models/native_navigation_config.dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../routing/app_router.dart';
import './models/native_tab_config.dart';


class NativeNavigationService {
  static const _channel = MethodChannel('native_navigation_channel');
  static final _navigationKey = GlobalKey<NavigatorState>();
  static final _scaffoldKey = GlobalKey<ScaffoldState>();
  static int _currentIndex = 0;
  static List<NativeTabConfig>? _currentTabs;
  static ValueNotifier<NavigationBar?> bottomNavigationBar = ValueNotifier(null);

  static Future<void> setupTabs(List<NativeTabConfig> tabs) async {
    _currentTabs = tabs;
    
    if (Platform.isIOS) {
      final tabsWithIcons = await Future.wait(
        tabs.map((tab) async {
          final normalIconData = await _renderIconData(tab.icon);
          final selectedIconData = tab.selectedIcon != null 
              ? await _renderIconData(tab.selectedIcon!)
              : null;
          
          return {
            'route': tab.route,
            'title': tab.title,
            'iconData': normalIconData,
            'selectedIconData': selectedIconData ?? normalIconData,
          };
        }),
      );
      
      await _channel.invokeMethod('setupTabs', {
        'tabs': tabsWithIcons,
      });

      _setupHotReloadListener();
    } else {
      _setupMaterialNavigation(tabs);
    }
  }

  static Future<Map<String, dynamic>> _renderIconData(IconData icon) async {
  final pictureRecorder = ui.PictureRecorder();
  final canvas = Canvas(pictureRecorder);
  final size = const Size(24.0, 24.0); // Standard icon size
  
  final paragraphBuilder = ui.ParagraphBuilder(ui.ParagraphStyle(
    fontFamily: icon.fontFamily,
    fontSize: 24,
  ))
    ..pushStyle(ui.TextStyle(
      color: Colors.black,
      fontFamily: icon.fontFamily,
      fontSize: 24,
      // Remove the package parameter as it's not supported in ui.TextStyle
    ))
    ..addText(String.fromCharCode(icon.codePoint));
  
  final paragraph = paragraphBuilder.build()
    ..layout(ui.ParagraphConstraints(width: size.width));
  
  canvas.drawParagraph(paragraph, Offset.zero);
  
  final picture = pictureRecorder.endRecording();
  final image = await picture.toImage(size.width.ceil(), size.height.ceil());
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  
  return {
    'data': byteData?.buffer.asUint8List(),
    'codePoint': icon.codePoint,
    'fontFamily': icon.fontFamily,
    'fontPackage': icon.fontPackage,
    'matchTextDirection': icon.matchTextDirection,
  };
}

  static void _setupMaterialNavigation(List<NativeTabConfig> tabs) {
    final navBar = NavigationBar(
      destinations: tabs.map((tab) {
        return NavigationDestination(
          icon: Icon(tab.icon),
          selectedIcon: tab.selectedIcon != null 
              ? Icon(tab.selectedIcon!)
              : Icon(tab.icon),
          label: tab.title,
        );
      }).toList(),
      selectedIndex: _currentIndex,
      onDestinationSelected: (index) {
        _currentIndex = index;
        final route = tabs[index].route;
        final args = tabs[index].arguments;
        AppRouter.router.go(route, extra: args);
      },
    );

    bottomNavigationBar.value = navBar;
  }

  static void _setupHotReloadListener() {
    const hotReloadChannel = EventChannel('flutter/hotReload');
    hotReloadChannel.receiveBroadcastStream().listen((_) {
      if (_currentTabs != null) {
        setupTabs(_currentTabs!);
      }
    });
  }

  static Future<void> updateNavigation(NativeNavigationConfig config) async {
    if (Platform.isIOS) {
      await _channel.invokeMethod('updateNavigation', config.toMap());
    }
  }

  static Future<void> updateTheme(ThemeData theme) async {
    if (Platform.isIOS) {
      await _channel.invokeMethod('updateTheme', {
        'backgroundColor': theme.appBarTheme.backgroundColor?.value,
        'tintColor': theme.primaryColor.value,
        'titleColor': theme.appBarTheme.titleTextStyle?.color?.value,
        'isDark': theme.brightness == Brightness.dark,
      });
    }
  }

  static void onBarButtonTap(void Function(String) callback) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onBarButtonTap') {
        callback(call.arguments['id'] as String);
      }
    });
  }

static void handleRouteChange(String route) {
  if (_currentTabs != null) {
    final index = _currentTabs!.indexWhere((tab) => tab.route == route);
    if (index != -1 && index != _currentIndex) {
      _currentIndex = index;
      if (!Platform.isIOS) {
        // Create a new NavigationBar with updated selectedIndex
        bottomNavigationBar.value = NavigationBar(
          destinations: bottomNavigationBar.value?.destinations ?? [],
          selectedIndex: _currentIndex,
          onDestinationSelected: bottomNavigationBar.value?.onDestinationSelected,
        );
      }
    }
  }
}
  // State management
  static ValueNotifier<NavigationBar?> get navigationBar => bottomNavigationBar;
  static int get currentIndex => _currentIndex;
}