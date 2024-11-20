import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import
import 'package:example_app/core/routing/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppRouter.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (_) {
        FocusManager.instance.primaryFocus?.unfocus();
        // Send dismiss event to native side
        const platform = MethodChannel('com.example.app/keyboard');
        platform.invokeMethod('dismissKeyboard');
      },
      child: MaterialApp.router(
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
