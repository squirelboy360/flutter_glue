import Flutter
import UIKit

class NativeTextInputFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return NativeTextInput(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger
        )
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

class NativeTextInput: NSObject, FlutterPlatformView, UITextFieldDelegate {
    private var _textField: UITextField
    private var _channel: FlutterMethodChannel
    private var _viewId: Int64

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger
    ) {
        _viewId = viewId
        _textField = UITextField()
        _channel = FlutterMethodChannel(name: "com.example.app/native_text_input_\(viewId)",
                                      binaryMessenger: messenger)
        
        super.init()
        
        // Configure text field
        _textField.frame = frame
        _textField.borderStyle = .none
        _textField.backgroundColor = .clear
        _textField.delegate = self
        
        // Apply initial configuration
        if let params = args as? [String: Any] {
            updateStyle(with: params)
        }
        
        // Setup method channel handler
        _channel.setMethodCallHandler { [weak self] (call, result) in
            guard let self = self else { return }
            
            switch call.method {
            case "setText":
                if let text = call.arguments as? String {
                    self._textField.text = text
                    result(nil)
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENTS",
                                      message: "Text argument is required",
                                      details: nil))
                }
                
            case "getText":
                result(self._textField.text ?? "")
                
            case "setPlaceholder":
                if let placeholder = call.arguments as? String {
                    self._textField.placeholder = placeholder
                    result(nil)
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENTS",
                                      message: "Placeholder argument is required",
                                      details: nil))
                }
                
            case "focus":
                self._textField.becomeFirstResponder()
                result(nil)
                
            case "clearFocus":
                self._textField.resignFirstResponder()
                result(nil)
                
            case "updateStyle":
                if let params = call.arguments as? [String: Any] {
                    self.updateStyle(with: params)
                    result(nil)
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENTS",
                                      message: "Style parameters are required",
                                      details: nil))
                }
                
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    func view() -> UIView {
        return _textField
    }
    
    private func updateStyle(with params: [String: Any]) {
        // Text style
        if let textStyle = params["textStyle"] as? [String: Any] {
            if let color = textStyle["color"] as? Int {
                _textField.textColor = UIColor(rgb: color)
            }
            if let fontSize = textStyle["fontSize"] as? CGFloat {
                _textField.font = .systemFont(ofSize: fontSize)
            }
            if let fontWeight = textStyle["fontWeight"] as? Int {
                _textField.font = .systemFont(ofSize: _textField.font?.pointSize ?? 17,
                                           weight: UIFont.Weight(rawValue: CGFloat(fontWeight)))
            }
        }
        
        // Placeholder
        if let placeholder = params["placeholder"] as? String {
            _textField.placeholder = placeholder
        }
        if let placeholderColor = params["placeholderColor"] as? Int {
            _textField.attributedPlaceholder = NSAttributedString(
                string: _textField.placeholder ?? "",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor(rgb: placeholderColor)]
            )
        }
        
        // Keyboard type
        if let keyboardType = params["keyboardType"] as? String {
            switch keyboardType {
            case "TextInputType.number":
                _textField.keyboardType = .numberPad
            case "TextInputType.phone":
                _textField.keyboardType = .phonePad
            case "TextInputType.emailAddress":
                _textField.keyboardType = .emailAddress
            case "TextInputType.url":
                _textField.keyboardType = .URL
            case "TextInputType.visiblePassword":
                _textField.keyboardType = .default
                _textField.isSecureTextEntry = false
            case "TextInputType.name":
                _textField.keyboardType = .namePhonePad
            case "TextInputType.streetAddress":
                _textField.keyboardType = .default
                _textField.textContentType = .streetAddressLine1
            case "TextInputType.none":
                _textField.keyboardType = .default
            default:
                _textField.keyboardType = .default
            }
        }
        
        // Other properties
        if let secure = params["secure"] as? Bool {
            _textField.isSecureTextEntry = secure
        }
        if let autocorrect = params["autocorrect"] as? Bool {
            _textField.autocorrectionType = autocorrect ? .yes : .no
        }
        
        // Visual styling
        if let backgroundColor = params["backgroundColor"] as? Int {
            _textField.backgroundColor = UIColor(rgb: backgroundColor)
        }
        if let cornerRadius = params["cornerRadius"] as? CGFloat {
            _textField.layer.cornerRadius = cornerRadius
            _textField.clipsToBounds = true
        }
        if let borderColor = params["borderColor"] as? Int {
            _textField.layer.borderColor = UIColor(rgb: borderColor).cgColor
        }
        if let borderWidth = params["borderWidth"] as? CGFloat {
            _textField.layer.borderWidth = borderWidth
        }
        if let padding = params["padding"] as? [String: CGFloat] {
            let left = padding["left"] ?? 0
            let right = padding["right"] ?? 0
            _textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: left, height: 0))
            _textField.leftViewMode = .always
            _textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: right, height: 0))
            _textField.rightViewMode = .always
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
           let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            _channel.invokeMethod("onChanged", arguments: ["text": updatedText])
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        _channel.invokeMethod("onFocusChanged", arguments: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        _channel.invokeMethod("onFocusChanged", arguments: false)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        _channel.invokeMethod("onSubmitted", arguments: ["text": textField.text ?? ""])
        _channel.invokeMethod("onEditingComplete", arguments: nil)
        return true
    }
}
