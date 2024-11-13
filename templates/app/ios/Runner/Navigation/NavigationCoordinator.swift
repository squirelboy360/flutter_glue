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
    private weak var navigationDelegate: NavigationChannel?
    
    private var routeStack: [String] = ["/"]
    
    init(navigationController: UINavigationController,
         flutterEngine: FlutterEngine,
         navigationDelegate: NavigationChannel) {
        self.navigationController = navigationController
        self.flutterEngine = flutterEngine
        self.navigationDelegate = navigationDelegate
    }
    
    func pushRoute(_ route: String, arguments: [String: Any]?, animated: Bool = true) {
        guard let flutterEngine = flutterEngine,
              let navigationController = navigationController else { return }
        
        let flutterVC = FlutterViewController(
            engine: flutterEngine,
            nibName: nil,
            bundle: nil
        )
        
        routeStack.append(route)
        
        // Configure back button if needed
        flutterVC.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(handleBackButton)
        )
        
        navigationController.pushViewController(flutterVC, animated: animated)
        navigationDelegate?.handleRouteChange(route, arguments: arguments)
    }
    
    func popRoute(animated: Bool = true) {
        guard routeStack.count > 1 else { return }
        
        routeStack.removeLast()
        navigationController?.popViewController(animated: animated)
        
        if let currentRoute = routeStack.last {
            navigationDelegate?.handleRouteChange(currentRoute)
        }
    }
    
    func setRoot(route: String, arguments: [String: Any]? = nil) {
        routeStack = [route]
        navigationDelegate?.handleRouteChange(route, arguments: arguments)
    }
    
    @objc private func handleBackButton() {
        popRoute()
    }
}
