package com.example.example_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import com.example.example_app.NativeTextInput.NativeTextInputFactory

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Register the NativeTextInputFactory
        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory(
                "native_text_input",
                NativeTextInputFactory(flutterEngine.dartExecutor.binaryMessenger)
            )
    }
}
