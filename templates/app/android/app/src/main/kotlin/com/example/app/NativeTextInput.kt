package com.example.app

import android.content.Context
import android.text.Editable
import android.text.TextWatcher
import android.view.View
import android.widget.EditText
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class NativeTextInputFactory(private val messenger: BinaryMessenger) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        return NativeTextInputView(context, viewId, args as? Map<String, Any>, messenger)
    }
}

class NativeTextInputView(
    context: Context,
    private val viewId: Int,
    private val args: Map<String, Any>?,
    private val messenger: BinaryMessenger
) : PlatformView {
    private val editText: EditText = EditText(context)
    private val channel: MethodChannel = MethodChannel(messenger, "native_text_input_$viewId")

    init {
        setupEditText()
        setupMethodChannel()
    }

    private fun setupEditText() {
        editText.apply {
            background = null
            args?.let { params ->
                // Text and placeholder
                text = (params["text"] as? String)?.let { Editable.Factory.getInstance().newEditable(it) }
                hint = params["placeholder"] as? String

                // Colors
                (params["textColor"] as? Int)?.let { setTextColor(it) }
                (params["placeholderColor"] as? Int)?.let { setHintTextColor(it) }

                // Font size
                (params["fontSize"] as? Float)?.let { textSize = it }

                // Input type
                when (params["keyboardType"] as? Int) {
                    1 -> inputType = android.text.InputType.TYPE_CLASS_NUMBER
                    2 -> inputType = android.text.InputType.TYPE_TEXT_FLAG_CAP_WORDS
                    3 -> inputType = android.text.InputType.TYPE_TEXT_FLAG_CAP_SENTENCES
                    else -> inputType = android.text.InputType.TYPE_CLASS_TEXT
                }

                // Max lines
                (params["maxLines"] as? Int)?.let { maxLines = it }
            }

            addTextChangedListener(object : TextWatcher {
                override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}
                override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {}
                override fun afterTextChanged(s: Editable?) {
                    channel.invokeMethod("onTextChanged", mapOf(
                        "text" to s.toString(),
                        "viewId" to viewId
                    ))
                }
            })

            setOnEditorActionListener { _, _, _ ->
                channel.invokeMethod("onSubmitted", mapOf(
                    "text" to text.toString(),
                    "viewId" to viewId
                ))
                true
            }
        }
    }

    private fun setupMethodChannel() {
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "setText" -> {
                    editText.setText(call.arguments as? String)
                    result.success(null)
                }
                "getText" -> {
                    result.success(editText.text.toString())
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun getView(): View = editText

    override fun dispose() {
        channel.setMethodCallHandler(null)
    }
}
