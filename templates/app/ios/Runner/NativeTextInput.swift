//
//  NativeTextInput.swift
//  Runner
//
//  Created by Tahiru Agbanwa on 11/20/24.
//

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
        return NativeTextInputView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args as? [String: Any],
            binaryMessenger: messenger)
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

class NativeTextInputView: NSObject, FlutterPlatformView, UITextFieldDelegate {
    private var textField: UITextField
    private var channel: FlutterMethodChannel
    private var viewId: Int64

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: [String: Any]?,
        binaryMessenger messenger: FlutterBinaryMessenger
    ) {
        self.textField = UITextField(frame: frame)
        self.viewId = viewId
        
        // Setup method channel
        self.channel = FlutterMethodChannel(
            name: "native_text_input_\(viewId)",
            binaryMessenger: messenger)
        
        super.init()
        
        // Configure text field
        setupTextField(with: args)
        setupMethodChannel()
    }

    func view() -> UIView {
        return textField
    }

    private func setupTextField(with args: [String: Any]?) {
        textField.borderStyle = .none
        textField.delegate = self
        
        if let args = args {
            // Text and placeholder
            if let text = args["text"] as? String {
                textField.text = text
            }
            if let placeholder = args["placeholder"] as? String {
                textField.placeholder = placeholder
            }
            
            // Colors
            if let textColor = args["textColor"] as? Int {
                textField.textColor = UIColor(rgb: UInt(textColor))
            }
            if let placeholderColor = args["placeholderColor"] as? Int {
                textField.attributedPlaceholder = NSAttributedString(
                    string: textField.placeholder ?? "",
                    attributes: [NSAttributedString.Key.foregroundColor: UIColor(rgb: UInt(placeholderColor))]
                )
            }
            
            // Font size
            if let fontSize = args["fontSize"] as? CGFloat {
                textField.font = .systemFont(ofSize: fontSize)
            }
            
            // Keyboard type
            if let keyboardType = args["keyboardType"] as? Int {
                switch keyboardType {
                case 1: textField.keyboardType = .numberPad
                case 2: textField.autocapitalizationType = .words
                case 3: textField.autocapitalizationType = .sentences
                default: textField.keyboardType = .default
                }
            }
            
            // Max lines
            if let maxLines = args["maxLines"] as? Int, maxLines > 1 {
                // Convert to UITextView if multiline is needed
                // This is a placeholder for future implementation
            }
        }
        
        // Add target for text changes
        textField.addTarget(
            self,
            action: #selector(textFieldDidChange(_:)),
            for: .editingChanged)
    }

    private func setupMethodChannel() {
        channel.setMethodCallHandler { [weak self] call, result in
            guard let self = self else { return }
            
            switch call.method {
            case "setText":
                if let text = call.arguments as? String {
                    self.textField.text = text
                    result(nil)
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENTS",
                                      message: "Text argument is required",
                                      details: nil))
                }
                
            case "focus":
                if let focus = (call.arguments as? [String: Any])?["focus"] as? Bool {
                    if focus {
                        self.textField.becomeFirstResponder()
                    } else {
                        self.textField.resignFirstResponder()
                    }
                    result(nil)
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENTS",
                                      message: "Focus argument is required",
                                      details: nil))
                }
                
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        channel.invokeMethod("onTextChanged", arguments: [
            "text": textField.text ?? "",
            "viewId": viewId
        ])
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        channel.invokeMethod("onSubmitted", arguments: [
            "text": textField.text ?? "",
            "viewId": viewId
        ])
        textField.resignFirstResponder()
        return true
    }
}

extension UIColor {
    convenience init(rgb: UInt) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: 1.0
        )
    }
}
