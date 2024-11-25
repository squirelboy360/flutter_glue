package com.example.app

import android.content.Context
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.text.InputType
import android.view.View
import android.view.ViewGroup
import android.view.inputmethod.EditorInfo
import android.widget.EditText
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class NativeTextInputFactory(private val messenger: BinaryMessenger) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val creationParams = args as? Map<String, Any>
        return NativeTextInput(context, viewId, creationParams, messenger)
    }
}

class NativeTextInput(
    context: Context,
    private val viewId: Int,
    private val creationParams: Map<String, Any>?,
    messenger: BinaryMessenger
) : PlatformView {

    private val editText: EditText = EditText(context)
    private val methodChannel: MethodChannel = MethodChannel(messenger, "com.example.app/native_text_input_$viewId")

    init {
        setupEditText()
        setupMethodChannel()
    }

    private fun setupEditText() {
        editText.layoutParams = ViewGroup.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.WRAP_CONTENT
        )

        creationParams?.let { params ->
            // Initial text
            params["initialText"]?.toString()?.let { text ->
                editText.setText(text)
            }

            // Text style
            (params["textStyle"] as? Map<*, *>)?.let { style ->
                style["color"]?.let { color ->
                    editText.setTextColor((color as Number).toInt())
                }
                style["fontSize"]?.let { size ->
                    when (size) {
                        is Number -> editText.textSize = size.toFloat()
                        is String -> size.toFloatOrNull()?.let { editText.textSize = it }
                    }
                }
                style["fontWeight"]?.let { weight ->
                    when (weight) {
                        is Number -> {
                            val typeface = when (weight.toInt()) {
                                0 -> Typeface.DEFAULT // normal
                                1 -> Typeface.DEFAULT_BOLD // bold
                                else -> Typeface.create(Typeface.DEFAULT, weight.toInt())
                            }
                            editText.typeface = typeface
                        }
                    }
                }
            }

            // Placeholder
            params["placeholder"]?.toString()?.let { hint ->
                editText.hint = hint
            }
            (params["placeholderColor"] as? Number)?.let { color ->
                editText.setHintTextColor(color.toInt())
            }

            // Background and border
            val background = GradientDrawable()
            (params["backgroundColor"] as? Number)?.let { color ->
                background.setColor(color.toInt())
            }
            (params["cornerRadius"] as? Number)?.let { radius ->
                background.cornerRadius = radius.toFloat()
            }
            (params["borderWidth"] as? Number)?.let { width ->
                (params["borderColor"] as? Number)?.let { color ->
                    background.setStroke(width.toInt(), color.toInt())
                }
            }
            editText.background = background

            // Padding
            (params["padding"] as? Map<*, *>)?.let { padding ->
                val left = (padding["left"] as? Number)?.toInt() ?: 16
                val top = (padding["top"] as? Number)?.toInt() ?: 8
                val right = (padding["right"] as? Number)?.toInt() ?: 16
                val bottom = (padding["bottom"] as? Number)?.toInt() ?: 8
                editText.setPadding(left, top, right, bottom)
            }

            // Keyboard type
            params["keyboardType"]?.toString()?.let { type ->
                var inputType = when (type) {
                    "TextInputType.number" -> InputType.TYPE_CLASS_NUMBER
                    "TextInputType.phone" -> InputType.TYPE_CLASS_PHONE
                    "TextInputType.datetime" -> InputType.TYPE_CLASS_DATETIME
                    "TextInputType.emailAddress" -> InputType.TYPE_CLASS_TEXT or InputType.TYPE_TEXT_VARIATION_EMAIL_ADDRESS
                    "TextInputType.url" -> InputType.TYPE_CLASS_TEXT or InputType.TYPE_TEXT_VARIATION_URI
                    "TextInputType.multiline" -> InputType.TYPE_CLASS_TEXT or InputType.TYPE_TEXT_FLAG_MULTI_LINE
                    else -> InputType.TYPE_CLASS_TEXT
                }
                
                // If multiline, also set these flags
                if (type == "TextInputType.multiline") {
                    editText.isSingleLine = false
                    editText.gravity = android.view.Gravity.TOP or android.view.Gravity.START
                }
                
                editText.inputType = inputType
            }

            // Security
            (params["secure"] as? Boolean)?.let { secure ->
                if (secure) {
                    editText.inputType = editText.inputType or InputType.TYPE_TEXT_VARIATION_PASSWORD
                }
            }

            // Autocorrect
            (params["autocorrect"] as? Boolean)?.let { autocorrect ->
                if (!autocorrect) {
                    editText.inputType = editText.inputType or InputType.TYPE_TEXT_FLAG_NO_SUGGESTIONS
                }
            }

            // Max lines
            params["maxLines"]?.let { lines ->
                when (lines) {
                    is Number -> editText.maxLines = lines.toInt()
                    is String -> lines.toIntOrNull()?.let { editText.maxLines = it }
                }
            }

            // Platform specific
            (params["platformSpecific"] as? Map<*, *>)?.let { platformSpecific ->
                // Handle Android specific configurations
                platformSpecific["textColorHint"]?.let { color ->
                    when (color) {
                        is Number -> editText.setHintTextColor(color.toInt())
                        is String -> try {
                            editText.setHintTextColor(Color.parseColor(color))
                        } catch (e: IllegalArgumentException) {
                            // Invalid color format
                        }
                    }
                }
                (platformSpecific["imeOptions"] as? String)?.let { options ->
                    when (options) {
                        "done" -> editText.imeOptions = EditorInfo.IME_ACTION_DONE
                        "next" -> editText.imeOptions = EditorInfo.IME_ACTION_NEXT
                        "search" -> editText.imeOptions = EditorInfo.IME_ACTION_SEARCH
                        "send" -> editText.imeOptions = EditorInfo.IME_ACTION_SEND
                        "go" -> editText.imeOptions = EditorInfo.IME_ACTION_GO
                    }
                }
            }
        }

        // Add text change listener
        editText.addTextChangedListener(object : android.text.TextWatcher {
            override fun afterTextChanged(s: android.text.Editable?) {
                methodChannel.invokeMethod("onChanged", mapOf("text" to s.toString()))
            }
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {}
        })

        // Set up editor action listener
        editText.setOnEditorActionListener { _, actionId, _ ->
            when (actionId) {
                EditorInfo.IME_ACTION_DONE -> {
                    methodChannel.invokeMethod("onEditingComplete", null)
                    methodChannel.invokeMethod("onSubmitted", mapOf("text" to editText.text.toString()))
                    true
                }
                else -> false
            }
        }
    }

    private fun setupMethodChannel() {
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "setText" -> {
                    editText.setText(call.arguments?.toString() ?: "")
                    result.success(null)
                }
                "updateStyle" -> {
                    val params = call.arguments as? Map<String, Any>
                    params?.let { styleParams ->
                        val background = GradientDrawable()
                        (styleParams["backgroundColor"] as? Number)?.let { color ->
                            background.setColor(color.toInt())
                        }
                        (styleParams["cornerRadius"] as? Number)?.let { radius ->
                            background.cornerRadius = radius.toFloat()
                        }
                        editText.background = background

                        (styleParams["textStyle"] as? Map<*, *>)?.let { style ->
                            style["fontSize"]?.let { size ->
                                when (size) {
                                    is Number -> editText.textSize = size.toFloat()
                                    is String -> size.toFloatOrNull()?.let { editText.textSize = it }
                                }
                            }
                        }
                    }
                    result.success(null)
                }
                "focus" -> {
                    editText.requestFocus()
                    result.success(null)
                }
                "clearFocus" -> {
                    editText.clearFocus()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun getView(): View = editText

    override fun dispose() {
        methodChannel.setMethodCallHandler(null)
    }
}
