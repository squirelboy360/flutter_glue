class NativeTabConfig {
  final String route;
  final String title;
  final String icon;
  final String? selectedIcon;
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
    'icon': icon,
    if (selectedIcon != null) 'selectedIcon': selectedIcon,
    if (arguments != null) 'arguments': arguments,
  };
}