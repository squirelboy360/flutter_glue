import Flutter
import UIKit

class NavigationChannel {
    static let shared = NavigationChannel()
    
    // Public properties
    var channel: FlutterMethodChannel?
    
    // Private properties
    private weak var flutterEngine: FlutterEngine?
    private weak var navigationController: UINavigationController?
    private weak var tabBarController: UITabBarController?
    
    private init() {}
    
    func setup(with engine: FlutterEngine, controller: FlutterViewController, tabController: UITabBarController) {
        self.flutterEngine = engine
        self.navigationController = controller.navigationController
        self.tabBarController = tabController
        
        channel = FlutterMethodChannel(
            name: "native_navigation_channel",
            binaryMessenger: controller.binaryMessenger
        )
        
        channel?.setMethodCallHandler { [weak self] call, result in
            guard let self = self else { return }
            
            switch call.method {
            case "setupTabs":
                self.handleSetupTabs(call.arguments, result: result)
            case "updateNavigation":
                self.handleUpdateNavigation(call.arguments, result: result)
            case "updateTheme":
                self.handleUpdateTheme(call.arguments, result: result)
            case "onBarButtonTap":
                self.handleBarButtonTap(call.arguments, result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
    
    private func handleSetupTabs(_ arguments: Any?, result: @escaping FlutterResult) {
        guard let args = arguments as? [String: Any],
              let tabs = args["tabs"] as? [[String: Any]] else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid tab configuration", details: nil))
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let tabBarController = self?.tabBarController else {
                result(FlutterError(code: "NO_TABBAR", message: "TabBarController not found", details: nil))
                return
            }
            
            // Create a new Flutter view controller for the first tab
            guard let flutterEngine = self?.flutterEngine else { return }
            let mainFlutterViewController = FlutterViewController(
                engine: flutterEngine,
                nibName: nil,
                bundle: nil
            )
            
            // Create navigation controllers
            var viewControllers: [UIViewController] = []
            
            // First tab with Flutter content
            let mainNavController = UINavigationController(rootViewController: mainFlutterViewController)
            if let firstTab = tabs.first,
               let title = firstTab["title"] as? String {
                mainNavController.tabBarItem = UITabBarItem(
                    title: title,
                    image: UIImage(systemName: "house"),
                    selectedImage: UIImage(systemName: "house.fill")
                )
            }
            viewControllers.append(mainNavController)
            
            // Additional tabs
            for (index, tabConfig) in tabs.enumerated() where index > 0 {
                if let title = tabConfig["title"] as? String {
                    let viewController = UIViewController()
                    let navController = UINavigationController(rootViewController: viewController)
                    navController.tabBarItem = UITabBarItem(
                        title: title,
                        image: UIImage(systemName: "star"),
                        selectedImage: UIImage(systemName: "star.fill")
                    )
                    viewControllers.append(navController)
                }
            }
            
            tabBarController.setViewControllers(viewControllers, animated: true)
            result(true)
        }
    }
    
    private func handleUpdateNavigation(_ arguments: Any?, result: @escaping FlutterResult) {
        guard let args = arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let navigationController = self?.navigationController else { return }
            
            if let title = args["title"] as? String {
                navigationController.topViewController?.title = title
            }
            
            if let rightButtons = args["rightButtons"] as? [[String: Any]] {
                navigationController.topViewController?.navigationItem.rightBarButtonItems =
                    self?.createBarButtonItems(from: rightButtons)
            }
            
            if let leftButtons = args["leftButtons"] as? [[String: Any]] {
                navigationController.topViewController?.navigationItem.leftBarButtonItems =
                    self?.createBarButtonItems(from: leftButtons)
            }
            
            if let styleArgs = args["style"] as? [String: Any] {
                let style = NavigationStyle(from: styleArgs)
                style.apply(to: navigationController.navigationBar)
            }
            
            result(true)
        }
    }
    
    private func handleUpdateTheme(_ arguments: Any?, result: @escaping FlutterResult) {
        guard let args = arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid theme data", details: nil))
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let navigationController = self?.navigationController else { return }
            
            let style = NavigationStyle(from: args)
            style.apply(to: navigationController.navigationBar)
            
            if let tabBar = self?.tabBarController?.tabBar {
                let theme = NavigationTheme()
                theme.apply(to: tabBar)
            }
            
            result(true)
        }
    }
    
    private func handleBarButtonTap(_ arguments: Any?, result: @escaping FlutterResult) {
        guard let args = arguments as? [String: Any],
              let buttonId = args["id"] as? String else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid button ID", details: nil))
            return
        }
        
        channel?.invokeMethod("onBarButtonTap", arguments: ["id": buttonId])
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
        channel?.invokeMethod("onBarButtonTap", arguments: ["id": id])
    }
}
