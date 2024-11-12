//
//  NavigationChannel.swift
//  Runner
//
//  Created by Tahiru Agbanwa on 11/12/24.
//

import Flutter
import UIKit

class NavigationChannel {
    static let shared = NavigationChannel()
    private var channel: FlutterMethodChannel?
    private weak var flutterEngine: FlutterEngine?
    
    private init() {}
    
    func setup(with engine: FlutterEngine, controller: FlutterViewController) {
        self.flutterEngine = engine
        
        channel = FlutterMethodChannel(
            name: "native_navigation_channel",
            binaryMessenger: controller.binaryMessenger
        )
        
        channel?.setMethodCallHandler { [weak self] call, result in
            guard let self = self else { return }
            
            switch call.method {
            case "updateNavigation":
                self.handleUpdateNavigation(call.arguments, result: result)
            case "updateTheme":
                self.handleUpdateTheme(call.arguments, result: result)
            case "setupTabs":
                self.handleSetupTabs(call.arguments, result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
    
    private func handleUpdateNavigation(_ arguments: Any?, result: @escaping FlutterResult) {
        guard let args = arguments as? [String: Any],
              let title = args["title"] as? String else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid navigation update", details: nil))
            return
        }
        
        DispatchQueue.main.async {
            if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController,
               let flutterViewController = navigationController.topViewController as? FlutterViewController {
                flutterViewController.title = title
                
                if let rightButtons = args["rightButtons"] as? [[String: Any]] {
                    flutterViewController.navigationItem.rightBarButtonItems = self.createBarButtonItems(from: rightButtons)
                }
                
                if let leftButtons = args["leftButtons"] as? [[String: Any]] {
                    flutterViewController.navigationItem.leftBarButtonItems = self.createBarButtonItems(from: leftButtons)
                }
            }
            
            result(true)
        }
    }
    
    private func handleUpdateTheme(_ arguments: Any?, result: @escaping FlutterResult) {
        guard let args = arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid theme data", details: nil))
            return
        }
        
        DispatchQueue.main.async {
            if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
                let style = NavigationStyle(from: args)
                style.apply(to: navigationController.navigationBar)
            }
            
            result(true)
        }
    }
    
    private func handleSetupTabs(_ arguments: Any?, result: @escaping FlutterResult) {
        guard let args = arguments as? [String: Any],
              let tabs = args["tabs"] as? [[String: Any]] else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid tabs data", details: nil))
            return
        }
        
        let tabController = AppTabBarController(engine: flutterEngine!, theme: NavigationTheme())
        tabController.configure(with: tabs)
        
        // Update the window's root view controller if necessary
        if let window = UIApplication.shared.keyWindow {
            window.rootViewController = tabController
            window.makeKeyAndVisible()
        }
        
        result(true)
    }
    
    private func createBarButtonItems(from buttons: [[String: Any]]) -> [UIBarButtonItem] {
        return buttons.compactMap { button in
            guard let id = button["id"] as? String else { return nil }
            
            let item: UIBarButtonItem
            
            if let systemName = button["systemName"] as? String {
                item = UIBarButtonItem(
                    image: UIImage(systemName: systemName),
                    style: .plain,
                    target: self,
                    action: #selector(handleBarButtonTap(_:))
                )
            } else if let title = button["title"] as? String {
                item = UIBarButtonItem(
                    title: title,
                    style: .plain,
                    target: self,
                    action: #selector(handleBarButtonTap(_:))
                )
            } else {
                return nil
            }
            
            item.accessibilityIdentifier = id
            return item
        }
    }
    
    @objc private func handleBarButtonTap(_ sender: UIBarButtonItem) {
        guard let id = sender.accessibilityIdentifier else { return }
        channel?.invokeMethod("onBarButtonTap", arguments: ["id": id])
    }
}

