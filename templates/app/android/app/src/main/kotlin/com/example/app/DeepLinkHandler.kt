package com.example.app

import android.content.Intent
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class DeepLinkHandler(flutterEngine: FlutterEngine) {
    private val channel: MethodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.app/deep_links")

    fun handleDeepLink(intent: Intent) {
        val data = intent.data
        if (data != null) {
            val deepLink = data.toString()
            channel.invokeMethod("handleDeepLink", deepLink)
        }
    }
}
