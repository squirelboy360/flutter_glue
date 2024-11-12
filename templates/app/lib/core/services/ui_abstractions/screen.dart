// lib/ui/widgets/native_screen.dart
import 'dart:io';

import 'package:example_app/core/services/native/navigation/models/native_navigation_config.dart.dart';
import 'package:example_app/core/services/native/navigation/native_navigation_service.dart';
import 'package:flutter/material.dart';

class NativeScreen extends StatefulWidget {
  final Widget child;
  final String title;
  final List<NativeBarButton>? rightButtons;
  final List<NativeBarButton>? leftButtons;
  final NativeNavigationStyle? style;
  final VoidCallback? onWillPop;

  const NativeScreen({
    super.key,
    required this.child,
    required this.title,
    this.rightButtons,
    this.leftButtons,
    this.style,
    this.onWillPop,
  });

  @override
  State<NativeScreen> createState() => _NativeScreenState();
}

class _NativeScreenState extends State<NativeScreen> with RouteAware {
  @override
  void initState() {
    super.initState();
    _updateNavigation();

    // Listen for native button taps
    if (Platform.isIOS) {
      NativeNavigationService.onBarButtonTap(_handleBarButtonTap);
    }
  }

  @override
  void didUpdateWidget(NativeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.title != widget.title ||
        oldWidget.rightButtons != widget.rightButtons ||
        oldWidget.leftButtons != widget.leftButtons ||
        oldWidget.style != widget.style) {
      _updateNavigation();
    }
  }

  Future<void> _updateNavigation() async {
    if (!Platform.isIOS) return;

    await NativeNavigationService.updateNavigation(
      NativeNavigationConfig(
        title: widget.title,
        rightButtons: widget.rightButtons,
        leftButtons: widget.leftButtons,
        style: widget.style ?? const NativeNavigationStyle(),
      ),
    );
  }

  void _handleBarButtonTap(String buttonId) {
    final buttons = [...widget.rightButtons ?? [], ...widget.leftButtons ?? []];
    final button = buttons.firstWhere(
      (b) => b.id == buttonId,
      orElse: () => throw Exception('Button not found: $buttonId'),
    );
    // Handle button tap
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return widget.child;
    }

    // Fall back to Material design on Android
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: widget.rightButtons?.map((button) {
          return IconButton(
            icon: const Icon(Icons.add), // Convert systemName to Material icon
            onPressed: () => _handleBarButtonTap(button.id),
          );
        }).toList(),
      ),
      body: widget.child,
    );
  }
}