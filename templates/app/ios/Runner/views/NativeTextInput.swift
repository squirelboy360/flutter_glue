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

class NativeTextInputView: NSObject, FlutterPlatformView, UITextFieldDelegate, UITextViewDelegate {
    private var textField: UITextField?
    private var textView: UITextView?
    private var activeView: UIView
    private var channel: FlutterMethodChannel
    private var viewId: Int64
    private var placeholder: String?
    private var placeholderColor: UIColor?
    private var isMultiline: Bool = false

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: [String: Any]?,
        binaryMessenger messenger: FlutterBinaryMessenger
    ) {
        self.viewId = viewId
        
        // Determine if multiline based on maxLines
        if let maxLines = args?["maxLines"] as? Int, maxLines > 1 {
            let textView = UITextView(frame: frame)
            self.textView = textView
            self.activeView = textView
            self.isMultiline = true
        } else {
            let textField = UITextField(frame: frame)
            self.textField = textField
            self.activeView = textField
            self.isMultiline = false
        }
        
        self.channel = FlutterMethodChannel(
            name: "com.example.app/native_text_input_\(viewId)",
            binaryMessenger: messenger)
        
        super.init()
        
        setupTextInput(with: args)
        setupMethodChannel()
    }

    func view() -> UIView {
        return activeView
    }

    private func setupTextInput(with args: [String: Any]?) {
        if isMultiline {
            setupTextView(with: args)
        } else {
            setupTextField(with: args)
        }
    }

    private func setupTextField(with args: [String: Any]?) {
        guard let textField = self.textField else { return }
        textField.delegate = self
        textField.borderStyle = .none
        
        if let args = args {
            configureCommonProperties(for: textField, with: args)
            
            // TextField specific configurations
            if let placeholder = args["placeholder"] as? String {
                textField.placeholder = placeholder
            }
            if let placeholderColor = args["placeholderColor"] as? Int {
                textField.attributedPlaceholder = NSAttributedString(
                    string: textField.placeholder ?? "",
                    attributes: [NSAttributedString.Key.foregroundColor: UIColor(hex: placeholderColor)]
                )
            }
            
            // Add target for text changes
            textField.addTarget(
                self,
                action: #selector(textFieldDidChange(_:)),
                for: .editingChanged
            )
        }
    }

    private func setupTextView(with args: [String: Any]?) {
        guard let textView = self.textView else { return }
        textView.delegate = self
        
        if let args = args {
            configureCommonProperties(for: textView, with: args)
            
            // TextView specific configurations
            if let placeholder = args["placeholder"] as? String {
                self.placeholder = placeholder
                if textView.text.isEmpty {
                    textView.text = placeholder
                    textView.textColor = placeholderColor ?? UIColor.lightGray
                }
            }
            
            // Configure text container insets for padding
            if let padding = args["padding"] as? [String: Any] {
                let left = (padding["left"] as? CGFloat) ?? 16
                let right = (padding["right"] as? CGFloat) ?? 16
                let top = (padding["top"] as? CGFloat) ?? 8
                let bottom = (padding["bottom"] as? CGFloat) ?? 8
                textView.textContainerInset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
            }
            
            // Handle max lines
            if let maxLines = args["maxLines"] as? Int {
                let maxHeight = CGFloat(maxLines) * (textView.font?.lineHeight ?? 20)
                textView.textContainer.maximumNumberOfLines = maxLines
                let heightConstraint = NSLayoutConstraint(
                    item: textView,
                    attribute: .height,
                    relatedBy: .lessThanOrEqual,
                    toItem: nil,
                    attribute: .notAnAttribute,
                    multiplier: 1,
                    constant: maxHeight
                )
                textView.addConstraint(heightConstraint)
            }
        }
    }

    private func configureCommonProperties(for view: UIView, with args: [String: Any]) {
        // Text style
        if let textStyle = args["textStyle"] as? [String: Any] {
            if let colorValue = textStyle["color"] as? Int {
                if let textField = view as? UITextField {
                    textField.textColor = UIColor(hex: colorValue)
                } else if let textView = view as? UITextView {
                    textView.textColor = UIColor(hex: colorValue)
                }
            }
            if let fontSize = textStyle["fontSize"] as? CGFloat {
                if let textField = view as? UITextField {
                    textField.font = .systemFont(ofSize: fontSize)
                } else if let textView = view as? UITextView {
                    textView.font = .systemFont(ofSize: fontSize)
                }
            }
        }
        
        // Background and border
        if let backgroundColor = args["backgroundColor"] as? Int {
            view.backgroundColor = UIColor(hex: backgroundColor)
        }
        
        if let cornerRadius = args["cornerRadius"] as? CGFloat {
            view.layer.cornerRadius = cornerRadius
            view.clipsToBounds = true
        }
        
        if let borderWidth = args["borderWidth"] as? CGFloat,
           let borderColor = args["borderColor"] as? Int {
            view.layer.borderWidth = borderWidth
            view.layer.borderColor = UIColor(hex: borderColor).cgColor
        }
        
        // Keyboard type
        let setKeyboardType: (UIKeyboardType) -> Void = { keyboardType in
            if let textField = view as? UITextField {
                textField.keyboardType = keyboardType
            } else if let textView = view as? UITextView {
                textView.keyboardType = keyboardType
            }
        }
        
        if let keyboardType = args["keyboardType"] as? String {
            switch keyboardType {
            case "TextInputType.number":
                setKeyboardType(.numberPad)
            case "TextInputType.phone":
                setKeyboardType(.phonePad)
            case "TextInputType.datetime":
                setKeyboardType(.numbersAndPunctuation)
            case "TextInputType.emailAddress":
                setKeyboardType(.emailAddress)
            case "TextInputType.url":
                setKeyboardType(.URL)
            default:
                setKeyboardType(.default)
            }
        }
        
        // Autocorrect
        if let autocorrect = args["autocorrect"] as? Bool {
            if let textField = view as? UITextField {
                textField.autocorrectionType = autocorrect ? .yes : .no
            } else if let textView = view as? UITextView {
                textView.autocorrectionType = autocorrect ? .yes : .no
            }
        }
        
        // Security
        if let secure = args["secure"] as? Bool {
            if let textField = view as? UITextField {
                textField.isSecureTextEntry = secure
            } else if let textView = view as? UITextView {
                textView.isSecureTextEntry = secure
            }
        }
    }

    private func setupMethodChannel() {
        channel.setMethodCallHandler { [weak self] call, result in
            guard let self = self else { return }
            
            switch call.method {
            case "setText":
                if let text = call.arguments as? String {
                    if let textField = self.textField {
                        textField.text = text
                    } else if let textView = self.textView {
                        textView.text = text
                    }
                }
                result(nil)
            case "updateStyle":
                if let args = call.arguments as? [String: Any] {
                    self.setupTextInput(with: args)
                }
                result(nil)
            case "focus":
                self.activeView.becomeFirstResponder()
                result(nil)
            case "clearFocus":
                self.activeView.resignFirstResponder()
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
    
    // UITextField delegate methods
    @objc private func textFieldDidChange(_ textField: UITextField) {
        channel.invokeMethod("onChanged", arguments: ["text": textField.text ?? ""])
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        channel.invokeMethod("onSubmitted", arguments: ["text": textField.text ?? ""])
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // UITextView delegate methods
    func textViewDidChange(_ textView: UITextView) {
        if textView.text != placeholder {
            channel.invokeMethod("onChanged", arguments: ["text": textView.text])
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholder {
            textView.text = ""
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholder
            textView.textColor = placeholderColor ?? UIColor.lightGray
        }
        channel.invokeMethod("onSubmitted", arguments: ["text": textView.text])
    }
}

extension UIColor {
    convenience init(hex: Int) {
        let red = CGFloat((hex >> 16) & 0xFF) / 255.0
        let green = CGFloat((hex >> 8) & 0xFF) / 255.0
        let blue = CGFloat(hex & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
