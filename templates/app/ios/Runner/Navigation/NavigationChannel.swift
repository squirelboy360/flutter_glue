//
//  NavigationChannel.swift
//  Runner
//
//  Created by Tahiru Agbanwa on 11/12/24.
//

import Foundation
import Flutter

class NavigationChannel {
    static let shared = NavigationChannel()

    private var flutterEngine: FlutterEngine?
    private var flutterViewController: FlutterViewController?
    private var methodChannel: FlutterMethodChannel?

    private init() {}

    func setup(with flutterEngine: FlutterEngine, controller: FlutterViewController) {
        self.flutterEngine = flutterEngine
        self.flutterViewController = controller
        
        methodChannel = FlutterMethodChannel(name: "com.example.app/navigation", binaryMessenger: flutterEngine.binaryMessenger)
        
        methodChannel?.setMethodCallHandler { [weak self] call, result in
            self?.handleMethodCall(call, result: result)
        }
    }

    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "updateTheme":
            handleUpdateTheme(arguments: call.arguments)
            result(nil)
        case "pushNewView":
            pushNewView(arguments: call.arguments)
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    func handleUpdateTheme(arguments: Any?) {
        guard let args = arguments as? [String: Any] else { return }
        if let theme = args["theme"] as? String {
            print("Updating theme to: \(theme)")
        }
    }

    func pushNewView(arguments: Any?) {
        guard let args = arguments as? [String: Any] else { return }
        if let viewName = args["viewName"] as? String {
            print("Pushing new view: \(viewName)")
        }
    }

    func callFlutterMethod(method: String, arguments: Any? = nil) {
        methodChannel?.invokeMethod(method, arguments: arguments)
    }
}
