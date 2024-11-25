package com.example.app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.os.Bundle
import android.content.Context
import android.view.inputmethod.InputMethodManager

class MainActivity: FlutterActivity() {
    private lateinit var deepLinkHandler: DeepLinkHandler

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Initialize deep link handler
        deepLinkHandler = DeepLinkHandler(flutterEngine)
        
        // Register platform view factory for native text input
        flutterEngine.platformViewsController.registry.registerViewFactory(
            "com.example.app/native_text_input",
            NativeTextInputFactory(flutterEngine.dartExecutor.binaryMessenger)
        )
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Handle deep link if activity was launched from a deep link
        intent?.let { handleIntent(it) }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent) {
        // Handle deep links
        if (intent.action == Intent.ACTION_VIEW) {
            deepLinkHandler.handleDeepLink(intent)
        }
    }
}
