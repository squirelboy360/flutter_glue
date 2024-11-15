package com.example.example_app.NativeTextInput

import android.content.Context
import android.graphics.Color
import android.text.InputType
import android.view.View
import android.widget.EditText
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import android.text.TextWatcher
import android.text.Editable
import android.view.inputmethod.EditorInfo

class NativeTextInputView(
    context: Context,
    private val viewId: Int,
    private val args: Map<String, Any>?,
    private val channel: MethodChannel
) : PlatformView {
    private val editText: EditText = EditText(context)

    init {
        setupEditText()
        setupTextWatcher()
        setupMethodChannel()
    }

    private fun setupEditText() {
        args?.let { params ->
            params["placeholder"]?.let { placeholder ->
                editText.hint = placeholder as String
            }

            params["placeholderColor"]?.let { color ->
                editText.setHintTextColor(color as Int)
            }

            params["textColor"]?.let { color ->
                editText.setTextColor(color as Int)
            }

            params["fontSize"]?.let { size ->
                editText.textSize = (size as Number).toFloat()
            }

            params["maxLines"]?.let { lines ->
                editText.maxLines = lines as Int
                if (lines > 1) {
                    editText.inputType = editText.inputType or InputType.TYPE_TEXT_FLAG_MULTI_LINE
                }
            }

            params["keyboardType"]?.let { type ->
                editText.inputType = getInputType(type as String)
            }

            params["textAlignment"]?.let { alignment ->
                editText.textAlignment = getTextAlignment(alignment as String)
            }
        }

        editText.setOnEditorActionListener { _, actionId, _ ->
            if (actionId == EditorInfo.IME_ACTION_DONE) {
                channel.invokeMethod("onEditingComplete", null)
                true
            } else {
                false
            }
        }
    }

    private fun setupTextWatcher() {
        editText.addTextChangedListener(object : TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}

            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
                channel.invokeMethod("onTextChanged", s?.toString() ?: "")
            }

            override fun afterTextChanged(s: Editable?) {}
        })
    }

    private fun setupMethodChannel() {
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "setText" -> {
                    val text = call.arguments as String?
                    editText.setText(text)
                    result.success(null)
                }
                "getText" -> {
                    result.success(editText.text.toString())
                }
                "setFocus" -> {
                    val focus = call.arguments as Boolean
                    if (focus) {
                        editText.requestFocus()
                    } else {
                        editText.clearFocus()
                    }
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun getInputType(type: String): Int {
        return when (type) {
            "number" -> InputType.TYPE_CLASS_NUMBER
            "email" -> InputType.TYPE_CLASS_TEXT or InputType.TYPE_TEXT_VARIATION_EMAIL_ADDRESS
            "phone" -> InputType.TYPE_CLASS_PHONE
            "url" -> InputType.TYPE_CLASS_TEXT or InputType.TYPE_TEXT_VARIATION_URI
            else -> InputType.TYPE_CLASS_TEXT
        }
    }

    private fun getTextAlignment(alignment: String): Int {
        return when (alignment) {
            "left" -> View.TEXT_ALIGNMENT_TEXT_START
            "center" -> View.TEXT_ALIGNMENT_CENTER
            "right" -> View.TEXT_ALIGNMENT_TEXT_END
            else -> View.TEXT_ALIGNMENT_TEXT_START
        }
    }

    override fun getView(): View = editText

    override fun dispose() {
        // Clean up resources
    }
}
