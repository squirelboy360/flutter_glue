//
//  TabBarController.swift
//  Runner
//
//  Created by Tahiru Agbanwa on 11/12/24.
//

import Flutter
import UIKit

class AppTabBarController: UITabBarController {
    private let flutterEngine: FlutterEngine
    private var navigationTheme: NavigationTheme
    private var tabConfigurations: [[String: Any]] = []
    
    init(engine: FlutterEngine, theme: NavigationTheme) {
        self.flutterEngine = engine
        self.navigationTheme = theme
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with tabs: [[String: Any]]) {
        tabConfigurations = tabs
        var viewControllers: [UIViewController] = []
        
        for (index, tab) in tabs.enumerated() {
            guard let route = tab["route"] as? String,
                  let title = tab["title"] as? String else { continue }
            
            let flutterVC = FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil)
            let navController = UINavigationController(rootViewController: flutterVC)
            
            navigationTheme.apply(to: navController.navigationBar)
            
            let tabBarItem = UITabBarItem(
                title: title,
                image: getTabIcon(from: tab, selected: false),
                selectedImage: getTabIcon(from: tab, selected: true)
            )
            navController.tabBarItem = tabBarItem
            
            let channel = FlutterMethodChannel(
                name: "native_navigation_channel",
                binaryMessenger: flutterVC.binaryMessenger
            )
            
            channel.invokeMethod("setRoute", arguments: [
                "route": route,
                "index": index,
                "arguments": tab["arguments"] ?? [:]
            ])
            
            viewControllers.append(navController)
        }
        
        setViewControllers(viewControllers, animated: false)
        navigationTheme.apply(to: tabBar)
    }
    
    private func getTabIcon(from tab: [String: Any], selected: Bool) -> UIImage? {
        if let iconName = tab["icon"] as? String {
            var name = iconName
            if selected, let selectedIcon = tab["selectedIcon"] as? String {
                name = selectedIcon
            }
            return UIImage(systemName: name)
        }
        return nil
    }
    
    func updateTheme(_ theme: NavigationTheme) {
        self.navigationTheme = theme
        navigationTheme.apply(to: tabBar)
        
        viewControllers?.forEach { viewController in
            if let navController = viewController as? UINavigationController {
                navigationTheme.apply(to: navController.navigationBar)
            }
        }
    }
}
