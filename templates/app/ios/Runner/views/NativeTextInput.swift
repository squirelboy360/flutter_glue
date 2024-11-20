import Flutter
import UIKit

class NativeTextInputFactory: NSObject, FlutterPlatformViewFactory {
    private let messenger: FlutterBinaryMessenger

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

class NativeTextInputView: NSObject, FlutterPlatformView, UITextFieldDelegate {
    private let textField: UITextField
    private var channel: FlutterMethodChannel?
    private let viewId: Int64

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        messenger: FlutterBinaryMessenger
    ) {
        self.viewId = viewId
        self.textField = UITextField(frame: frame)
        super.init()

        // Setup text field
        textField.delegate = self
        textField.borderStyle = .none
        textField.backgroundColor = .clear
        textField.tag = Int(viewId)

        // Setup method channel
        channel = FlutterMethodChannel(
            name: "native_text_input_\(viewId)",
            binaryMessenger: messenger
        )

        // Configure with arguments
        if let params = args as? [String: Any] {
            configureTextField(with: params)
        }

        setupMethodChannel()
        setupTextFieldCallbacks()
    }

    private func configureTextField(with params: [String: Any]) {
        // Text and placeholder
        if let text = params["text"] as? String {
            textField.text = text
        }
        if let placeholder = params["placeholder"] as? String {
            textField.placeholder = placeholder
        }

        // Colors
        if let textColorValue = params["textColor"] as? Int {
            textField.textColor = UIColor(rgb: textColorValue)
        }
        if let placeholderColorValue = params["placeholderColor"] as? Int {
            textField.attributedPlaceholder = NSAttributedString(
                string: textField.placeholder ?? "",
                attributes: [.foregroundColor: UIColor(rgb: placeholderColorValue)]
            )
        }

        // Font size
        if let fontSize = params["fontSize"] as? CGFloat {
            textField.font = .systemFont(ofSize: fontSize)
        }

        // Keyboard type
        if let keyboardType = params["keyboardType"] as? Int {
            textField.keyboardType = UIKeyboardType(rawValue: keyboardType) ?? .default
        }

        // Text capitalization
        if let capitalization = params["textCapitalization"] as? Int {
            switch capitalization {
            case 1: textField.autocapitalizationType = .words
            case 2: textField.autocapitalizationType = .sentences
            case 3: textField.autocapitalizationType = .allCharacters
            default: textField.autocapitalizationType = .none
            }
        }
    }

    private func setupTextFieldCallbacks() {
        textField.addTarget(
            self,
            action: #selector(textFieldDidChange),
            for: .editingChanged
        )
    }

    private func setupMethodChannel() {
        channel?.setMethodCallHandler { [weak self] call, result in
            guard let self = self else { return }
            
            switch call.method {
            case "setText":
                if let text = call.arguments as? String {
                    self.textField.text = text
                }
                result(nil)
            case "getText":
                result(self.textField.text ?? "")
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    @objc private func textFieldDidChange() {
        channel?.invokeMethod("onTextChanged", arguments: [
            "text": textField.text ?? "",
            "viewId": viewId
        ])
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        channel?.invokeMethod("onSubmitted", arguments: [
            "text": textField.text ?? "",
            "viewId": viewId
        ])
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func view() -> UIView {
        return textField
    }
}
