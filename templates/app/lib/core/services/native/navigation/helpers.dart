import 'package:example_app/core/services/native/navigation/models/native_tab_config.dart';
import 'package:example_app/core/services/native/navigation/native_navigation_service.dart';

Future<void> setupTabs() async {
    final tabs = [
      const NativeTabConfig(
        route: '/',
        title: 'Home',
        icon: 'house',
        selectedIcon: 'house.fill',
      ),
      const NativeTabConfig(
        route: '/example',
        title: 'Example',
        icon: 'star',
        selectedIcon: 'star.fill',
      ),
    ];

    await NativeNavigationService.setupTabs(tabs);
  }
