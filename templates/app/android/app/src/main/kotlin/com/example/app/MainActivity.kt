package com.example.app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Register platform view factory for native text input
        flutterEngine.platformViewsController.registry.registerViewFactory(
            "com.example.app/native_text_input",
            NativeTextInputFactory(flutterEngine.dartExecutor.binaryMessenger)
        )
    }
}
