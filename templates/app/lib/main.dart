
import 'dart:io';

import 'package:example_app/core/services/native/navigation/native_navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:example_app/core/routing/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize router
  AppRouter.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Your theme configuration
      ),
      builder: (context, child) {
        // Sync theme with native navigation if on iOS
        if (Platform.isIOS) {
          NativeNavigationService.updateTheme(Theme.of(context));
        }
        
        return child!;
      },
    );
  }
}