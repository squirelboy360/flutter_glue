//
//  NativeTextInput.swift
//  Runner
//
//  Created by Tahiru Agbanwa on 11/15/24.
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
            arguments: args,
            messenger: messenger
        )
    }
    
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

class NativeTextInputView: NSObject, FlutterPlatformView {
    private let textView: UITextView
    private var channel: FlutterMethodChannel?
    
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        messenger: FlutterBinaryMessenger
    ) {
        textView = UITextView(frame: frame)
        super.init()
        
        // Setup method channel for this instance
        channel = FlutterMethodChannel(
            name: "native_text_input_\(viewId)",
            binaryMessenger: messenger
        )
        
        // Configure the text view
        setupTextView(with: args)
        setupMethodChannel()
    }
    
    private func setupTextView(with arguments: Any?) {
        guard let args = arguments as? [String: Any] else { return }
        
        // Configure appearance
        textView.backgroundColor = .clear
        let fontSize = (args["fontSize"] as? NSNumber)?.doubleValue ?? 16.0
        textView.font = UIFont.systemFont(ofSize: CGFloat(fontSize))
        textView.textColor = UIColor(rgb: args["textColor"] as? Int ?? 0x000000)
        
        // Configure behavior
        textView.isEditable = args["editable"] as? Bool ?? true
        textView.isSelectable = args["selectable"] as? Bool ?? true
        textView.isScrollEnabled = args["scrollable"] as? Bool ?? true
        
        // Set content
        if let placeholder = args["placeholder"] as? String {
            textView.text = placeholder
            textView.textColor = UIColor.lightGray
        }
        
        // Add target for text changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textDidChange),
            name: UITextView.textDidChangeNotification,
            object: textView
        )
    }
    
    private func setupMethodChannel() {
        channel?.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            guard let self = self else { return }
            
            switch call.method {
            case "setText":
                if let text = call.arguments as? String {
                    self.textView.text = text
                }
                result(nil)
                
            case "getText":
                result(self.textView.text)
                
            case "setPlaceholder":
                if let placeholder = call.arguments as? String {
                    self.textView.text = placeholder
                    self.textView.textColor = .lightGray
                }
                result(nil)
                
            case "clear":
                self.textView.text = ""
                result(nil)
                
            case "focus":
                self.textView.becomeFirstResponder()
                result(nil)
                
            case "unfocus":
                self.textView.resignFirstResponder()
                result(nil)
                
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
    
    @objc private func textDidChange() {
        channel?.invokeMethod("onTextChanged", arguments: textView.text)
    }
    
    func view() -> UIView {
        return textView
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
