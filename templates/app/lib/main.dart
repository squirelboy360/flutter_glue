
import 'package:flutter/material.dart';
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
    return MaterialApp.router(
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}

 
