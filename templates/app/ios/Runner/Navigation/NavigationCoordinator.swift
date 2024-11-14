//
//  NavigationCoordinator.swift
//  Runner
//
//  Created by Tahiru Agbanwa on 11/13/24.
//

import Flutter
import UIKit

class NavigationCoordinator {
    private weak var navigationController: UINavigationController?
    private weak var flutterEngine: FlutterEngine?
    private var currentRoute: String = "/"
    private var navigationStack: [String] = ["/"]
    
    init(navigationController: UINavigationController, engine: FlutterEngine) {
        self.navigationController = navigationController
        self.flutterEngine = engine
    }
    
    func pushViewController(route: String, title: String?, arguments: [String: Any]? = nil, animated: Bool = true) {
        guard let engine = flutterEngine else { return }
        
        // Store current view controller's engine reference
        let currentVC = engine.viewController
        
        // Create new Flutter VC
        let flutterVC = FlutterViewController(engine: engine, nibName: nil, bundle: nil)
        flutterVC.title = title
        
        // Push and update route
        navigationController?.pushViewController(flutterVC, animated: animated)
        
        // Update navigation stack
        navigationStack.append(route)
        currentRoute = route
        
        // Update route in Flutter after navigation is complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            NavigationChannel.shared.channel?.invokeMethod("setRoute", arguments: [
                "route": route,
                "arguments": arguments ?? [:]
            ])
        }
    }
    
    func popViewController(animated: Bool = true) {
        guard let navigationController = navigationController,
              navigationController.viewControllers.count > 1 else { return }
        
        // Remove current route from stack
        navigationStack.removeLast()
        
        // Get previous route
        currentRoute = navigationStack.last ?? "/"
        
        // Pop view controller
        navigationController.popViewController(animated: animated)
        
        // Update route in Flutter
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            NavigationChannel.shared.channel?.invokeMethod("setRoute", arguments: [
                "route": self.currentRoute,
                "arguments": [:]
            ])
        }
    }
    
    func popToRoot(animated: Bool = true) {
        guard let navigationController = navigationController,
              navigationController.viewControllers.count > 1 else { return }
        
        // Reset navigation stack
        navigationStack = ["/"]
        currentRoute = "/"
        
        // Pop to root
        navigationController.popToRootViewController(animated: animated)
        
        // Update route in Flutter
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            NavigationChannel.shared.channel?.invokeMethod("setRoute", arguments: [
                "route": "/",
                "arguments": [:]
            ])
        }
    }
    
    func setNavigationBarHidden(_ hidden: Bool, animated: Bool = true) {
        navigationController?.setNavigationBarHidden(hidden, animated: animated)
    }
    
    func configureNavigationBar(with config: [String: Any]) {
        guard let navigationController = navigationController else { return }
        
        if let title = config["title"] as? String {
            navigationController.topViewController?.title = title
        }
        
        if let rightButtons = config["rightButtons"] as? [[String: Any]] {
            let items = createBarButtonItems(from: rightButtons)
            navigationController.topViewController?.navigationItem.rightBarButtonItems = items
        }
        
        if let leftButtons = config["leftButtons"] as? [[String: Any]] {
            let items = createBarButtonItems(from: leftButtons)
            navigationController.topViewController?.navigationItem.leftBarButtonItems = items
        }
        
        if let style = config["style"] as? [String: Any] {
            let navStyle = NavigationStyle(from: style)
            navStyle.apply(to: navigationController.navigationBar)
        }
    }
    
    private func createBarButtonItems(from buttons: [[String: Any]]) -> [UIBarButtonItem] {
        return buttons.compactMap { button in
            guard let id = button["id"] as? String else { return nil }
            
            let item: UIBarButtonItem
            
            if let systemName = button["systemName"] as? String {
                item = UIBarButtonItem(
                    image: UIImage(systemName: systemName)?
                        .withConfiguration(UIImage.SymbolConfiguration(scale: .large)),
                    style: .plain,
                    target: self,
                    action: #selector(barButtonTapped(_:))
                )
            } else if let title = button["title"] as? String {
                item = UIBarButtonItem(
                    title: title,
                    style: .plain,
                    target: self,
                    action: #selector(barButtonTapped(_:))
                )
            } else {
                return nil
            }
            
            item.accessibilityIdentifier = id
            return item
        }
    }
    
    @objc private func barButtonTapped(_ sender: UIBarButtonItem) {
        guard let id = sender.accessibilityIdentifier else { return }
        NavigationChannel.shared.channel?.invokeMethod("onBarButtonTap", arguments: ["id": id])
    }
    
    func getCurrentRoute() -> String {
        return currentRoute
    }
    
    func getNavigationStack() -> [String] {
        return navigationStack
    }
}