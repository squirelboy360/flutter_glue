import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class Wrapper extends StatelessWidget {
 final Widget child;
 const Wrapper({super.key, required this.child});

 @override
 Widget build(BuildContext context) => PopScope(
   canPop: false,
   key: UniqueKey(),
   child: MaterialApp(
     debugShowCheckedModeBanner: false,
     theme: ThemeData(
       pageTransitionsTheme: const PageTransitionsTheme(
         builders: {
           TargetPlatform.android: NoTransitionsBuilder(),
           TargetPlatform.iOS: NoTransitionsBuilder(),
           TargetPlatform.macOS: NoTransitionsBuilder(),
           TargetPlatform.windows: NoTransitionsBuilder(),
           TargetPlatform.linux: NoTransitionsBuilder(),
         },
       ),
     ),
     builder: (context, child) => FTheme(
       data: FThemes.zinc.light,
       child: child!,
     ),
     home: FScaffold(
       content: !kIsWeb & Platform.isIOS || Platform.isAndroid
         ? PrimaryScrollController( 
             controller: ScrollController(),  // Add this line
             child: Builder(
               builder: (context) => Scrollbar(
                 controller: PrimaryScrollController.of(context),
                 interactive: true,
                 child: child,
               ),
             ),
           )
         : child,
       contentPad: false,
     )
   ),
 );
}

class NoTransitionsBuilder extends PageTransitionsBuilder {
 const NoTransitionsBuilder();

 @override
 Widget buildTransitions<T>(
   PageRoute<T> route,
   BuildContext context,
   Animation<double> animation,
   Animation<double> secondaryAnimation,
   Widget child,
 ) {
   return child;
 }
}