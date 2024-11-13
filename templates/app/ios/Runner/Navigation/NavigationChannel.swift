import Flutter
import UIKit

class NavigationChannel {
    static let shared = NavigationChannel()
    var channel: FlutterMethodChannel?
    
    private weak var flutterEngine: FlutterEngine?
    private var navigationStack: [String] = ["/"]
    private weak var rootNavigationController: UINavigationController?
    private weak var tabBarController: UITabBarController?
    private var currentRoute: String = "/"
    
    private init() {}
    
    func setup(with engine: FlutterEngine, controller: FlutterViewController, tabController: UITabBarController) {
        self.flutterEngine = engine
        self.tabBarController = tabController
        
        let rootNavController = UINavigationController(rootViewController: controller)
        self.rootNavigationController = rootNavController
        
        channel = FlutterMethodChannel(
            name: "native_navigation_channel",
            binaryMessenger: controller.binaryMessenger
        )
        
        setupMethodHandler()
    }
    
    private func setupMethodHandler() {
        channel?.setMethodCallHandler { [weak self] call, result in
            guard let self = self else { return }
            
            switch call.method {
            case "setupTabs":
                self.handleSetupTabs(call.arguments, result: result)
            case "pushRoute":
                self.handlePushRoute(call.arguments, result: result)
            case "popRoute":
                self.handlePopRoute(result: result)
            case "updateNavigation":
                self.handleUpdateNavigation(call.arguments, result: result)
            case "updateTheme":
                self.handleUpdateTheme(call.arguments, result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
    
    private func handlePushRoute(_ arguments: Any?, result: @escaping FlutterResult) {
        guard let args = arguments as? [String: Any],
              let route = args["route"] as? String,
              let engine = flutterEngine else {
            result(false)
            return
        }
        
        navigationStack.append(route)
        currentRoute = route
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Create new route view
            let flutterVC = FlutterViewController(engine: engine, nibName: nil, bundle: nil)
            
            if let title = args["title"] as? String {
                flutterVC.title = title
            }
            
            // Configure navigation item
            if let config = args["navigationConfig"] as? [String: Any] {
                self.configureNavigationItem(for: flutterVC, with: config)
            }
            
            // Push to native stack
            self.rootNavigationController?.pushViewController(flutterVC, animated: true)
            
            // Notify Flutter of route change
            self.channel?.invokeMethod("setRoute", arguments: [
                "route": route,
                "arguments": args["arguments"] ?? [:]
            ])
            
            result(true)
        }
    }
    
    private func handlePopRoute(_ result: @escaping FlutterResult) {
        guard navigationStack.count > 1 else {
            result(false)
            return
        }
        
        navigationStack.removeLast()
        currentRoute = navigationStack.last ?? "/"
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.rootNavigationController?.popViewController(animated: true)
            
            self.channel?.invokeMethod("setRoute", arguments: [
                "route": self.currentRoute,
                "arguments": [:]
            ])
            
            result(true)
        }
    }
    
    private func handleSetupTabs(_ arguments: Any?, result: @escaping FlutterResult) {
        guard let args = arguments as? [String: Any],
              let tabs = args["tabs"] as? [[String: Any]] else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid tab configuration", details: nil))
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let engine = self.flutterEngine,
                  let tabController = self.tabBarController else {
                result(FlutterError(code: "NO_TABBAR", message: "TabBarController not found", details: nil))
                return
            }
            
            let viewControllers = tabs.enumerated().map { [weak self] (index, config) -> UIViewController in
                let flutterVC = FlutterViewController(engine: engine, nibName: nil, bundle: nil)
                let navController = UINavigationController(rootViewController: flutterVC)
                
                if let title = config["title"] as? String {
                    self?.configureTab(navController, title: title, config: config)
                }
                
                return navController
            }
            
            tabController.setViewControllers(viewControllers, animated: false)
            result(true)
            
            // Set initial route
            if let route = tabs.first?["route"] as? String {
                self.handleRouteChange(route)
            }
        }
    }
    
    private func configureTab(_ controller: UINavigationController, title: String, config: [String: Any]) {
        if let iconData = config["iconData"] as? FlutterStandardTypedData {
            let icon = UIImage(data: iconData.data)?
                .withRenderingMode(.alwaysTemplate)
                .withConfiguration(UIImage.SymbolConfiguration(scale: .large))
            
            controller.tabBarItem = UITabBarItem(
                title: title,
                image: icon,
                selectedImage: icon
            )
        }
    }
    
    private func handleUpdateNavigation(_ arguments: Any?, result: @escaping FlutterResult) {
        guard let args = arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let navigationController = self?.rootNavigationController else { return }
            
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
            
            result(true)
        }
    }
    
    private func handleUpdateTheme(_ arguments: Any?, result: @escaping FlutterResult) {
        guard let args = arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid theme data", details: nil))
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let navigationController = self?.rootNavigationController else { return }
            
            let style = NavigationStyle(from: args)
            style.apply(to: navigationController.navigationBar)
            
            if let tabBar = self?.tabBarController?.tabBar {
                let theme = NavigationTheme()
                theme.apply(to: tabBar)
            }
            
            result(true)
        }
    }
    
    private func configureNavigationItem(for controller: FlutterViewController, with config: [String: Any]) {
        if let rightButtons = config["rightButtons"] as? [[String: Any]] {
            controller.navigationItem.rightBarButtonItems = createBarButtonItems(from: rightButtons)
        }
        
        if let leftButtons = config["leftButtons"] as? [[String: Any]] {
            controller.navigationItem.leftBarButtonItems = createBarButtonItems(from: leftButtons)
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
        channel?.invokeMethod("onBarButtonTap", arguments: ["id": id])
    }
    
    func handleRouteChange(_ route: String, arguments: [String: Any]? = nil) {
        currentRoute = route
        channel?.invokeMethod("setRoute", arguments: [
            "route": route,
            "arguments": arguments ?? [:]
        ])
    }
    
    func getRootNavigationController() -> UINavigationController? {
        return rootNavigationController
    }
}
