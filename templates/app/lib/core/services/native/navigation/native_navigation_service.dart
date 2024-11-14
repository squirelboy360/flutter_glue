import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../routing/app_router.dart';

import './models/native_tab_config.dart';
import 'models/native_navigation_config.dart.dart';

class NativeNavigationService {
  static const _channel = MethodChannel('native_navigation_channel');
  static const _modalChannel = MethodChannel('native_modal_channel');
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
      _setupRouteListener();
      _setupModalListener();
    } else {
      _setupMaterialNavigation(tabs);
    }
  }

  static void onBarButtonTap(void Function(String) callback) {
    if (!Platform.isIOS) return;

    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onBarButtonTap') {
        callback(call.arguments['id'] as String);
      }
      // Keep the existing route handling
      if (call.method == 'setRoute') {
        final args = call.arguments as Map<String, dynamic>;
        final route = args['route'] as String;
        final arguments = args['arguments'] as Map<String, dynamic>?;
        AppRouter.router.go(route, extra: arguments);
      }
    });
  }

  static Future<Map<String, dynamic>> _renderIconData(IconData icon) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    const size = Size(24.0, 24.0);

    final paragraphBuilder = ui.ParagraphBuilder(ui.ParagraphStyle(
      fontFamily: icon.fontFamily,
      fontSize: 24,
    ))
      ..pushStyle(ui.TextStyle(
        color: Colors.black,
        fontFamily: icon.fontFamily,
        fontSize: 24,
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

  static void _setupRouteListener() {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'setRoute':
          final args = call.arguments as Map<String, dynamic>;
          final route = args['route'] as String;
          final arguments = args['arguments'] as Map<String, dynamic>?;

          // Use GoRouter to navigate
          AppRouter.router.go(route, extra: arguments);
          break;

        case 'onBarButtonTap':
          final id = call.arguments['id'] as String;
          handleBarButtonTap(id);
          break;
      }
    });
  }

  static void _setupModalListener() {
    _modalChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'setRoute':
          final args = call.arguments as Map<String, dynamic>;
          final route = args['route'] as String;
          final arguments = args['arguments'] as Map<String, dynamic>?;
          final modalId = args['modalId'] as String?;

          if (modalId != null) {
            // Handle modal route changes
            handleModalRouteChange(route, modalId, arguments);
          }
          break;
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

  static void handleRouteChange(String route, {Map<String, dynamic>? arguments}) {
    if (_currentTabs != null) {
      final index = _currentTabs!.indexWhere((tab) => tab.route == route);
      if (index != -1 && index != _currentIndex) {
        _currentIndex = index;
        if (!Platform.isIOS) {
          bottomNavigationBar.value = NavigationBar(
            destinations: bottomNavigationBar.value?.destinations ?? [],
            selectedIndex: _currentIndex,
            onDestinationSelected: bottomNavigationBar.value?.onDestinationSelected,
          );
        }
      }
    }
  }

  static void handleModalRouteChange(String route, String modalId, Map<String, dynamic>? arguments) {
    // Handle modal-specific route changes
    // This can be extended based on your modal navigation needs
  }

  static void handleBarButtonTap(String buttonId) {
    // Implement bar button tap handling
    // This can be customized based on your needs
  }

  // Modal presentation methods
  static Future<String?> showModal({
    required String route,
    Map<String, dynamic>? arguments,
    bool isDismissible = true,
    bool showDragIndicator = true,
    bool showHeader = true,
    String? headerTitle,
    bool showCloseButton = false,
    String presentationStyle = 'pageSheet',
    List<String> detents = const ['large'],
  }) async {
    if (!Platform.isIOS) return null;

    try {
      final result = await _modalChannel.invokeMethod('showModal', {
        'route': route,
        'arguments': arguments ?? {},
        'isDismissible': isDismissible,
        'showDragIndicator': showDragIndicator,
        'showHeader': showHeader,
        'headerTitle': headerTitle,
        'showCloseButton': showCloseButton,
        'presentationStyle': presentationStyle,
        'detents': detents,
      });

      return result as String?;
    } catch (e) {
      debugPrint('Error showing modal: $e');
      return null;
    }
  }

  static Future<bool> dismissModal(String modalId) async {
    if (!Platform.isIOS) return false;

    try {
      final result = await _modalChannel.invokeMethod('dismissModal', {
        'modalId': modalId,
      });
      return result as bool;
    } catch (e) {
      debugPrint('Error dismissing modal: $e');
      return false;
    }
  }

  static Future<int> dismissAllModals() async {
    if (!Platform.isIOS) return 0;

    try {
      final result = await _modalChannel.invokeMethod('dismissAllModals');
      return (result as Map)['dismissedCount'] as int;
    } catch (e) {
      debugPrint('Error dismissing all modals: $e');
      return 0;
    }
  }

  // Getters for state management
  static ValueNotifier<NavigationBar?> get navigationBar => bottomNavigationBar;
  static int get currentIndex => _currentIndex;
  static GlobalKey<NavigatorState> get navigatorKey => _navigationKey;
  static GlobalKey<ScaffoldState> get scaffoldKey => _scaffoldKey;
}