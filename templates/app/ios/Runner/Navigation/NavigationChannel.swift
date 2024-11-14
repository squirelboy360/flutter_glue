import Flutter
import UIKit

class NavigationChannel {
    static let shared = NavigationChannel()
    var channel: FlutterMethodChannel?
    var currentRoute: String = "/"
    
    private weak var flutterEngine: FlutterEngine?
    private weak var rootNavigationController: UINavigationController?
    private weak var tabBarController: CustomTabBarController?
    private var navigationStack: [String] = ["/"]
    
    private init() {}
    
    func setup(with engine: FlutterEngine, controller: FlutterViewController, tabController: CustomTabBarController) {
        self.flutterEngine = engine
        self.rootNavigationController = controller.navigationController
        self.tabBarController = tabController
        
        channel = FlutterMethodChannel(
            name: "native_navigation_channel",
            binaryMessenger: controller.binaryMessenger
        )
        
        setupMethodHandler()
        
        DispatchQueue.main.async {
            self.handleRouteChange("/")
        }
    }
    
    private func setupMethodHandler() {
        channel?.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            guard let self = self else { return }
            
            switch call.method {
            case "setupTabs":
                self.handleSetupTabs(arguments: call.arguments, result: result)
            case "pushRoute":
                self.handlePushRoute(arguments: call.arguments, result: result)
            case "popRoute":
                self.handlePopRoute(result: result)
            case "updateNavigation":
                self.handleUpdateNavigation(arguments: call.arguments, result: result)
            case "updateTheme":
                self.handleUpdateTheme(arguments: call.arguments, result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
    
    private func handlePushRoute(arguments: Any?, result: @escaping FlutterResult) {
        guard let args = arguments as? [String: Any],
              let route = args["route"] as? String,
              let engine = flutterEngine else {
            result(false)
            return
        }
        
        // Detach engine from current VC
        engine.viewController = nil
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let flutterVC = FlutterViewController(engine: engine, nibName: nil, bundle: nil)
            
            if let title = args["title"] as? String {
                flutterVC.title = title
            }
            
            // Configure navigation buttons if needed
            if let navConfig = args["navigationConfig"] as? [String: Any] {
                self.configureNavigationItems(for: flutterVC, with: navConfig)
            }
            
            self.rootNavigationController?.pushViewController(flutterVC, animated: true)
            self.navigationStack.append(route)
            self.currentRoute = route
            
            self.channel?.invokeMethod("setRoute", arguments: [
                "route": route,
                "arguments": args["arguments"] ?? [:]
            ])
            
            result(true)
        }
    }
    
    private func handlePopRoute(result: @escaping FlutterResult) {
        guard navigationStack.count > 1 else {
            result(false)
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.navigationStack.removeLast()
            self.currentRoute = self.navigationStack.last ?? "/"
            
            self.rootNavigationController?.popViewController(animated: true)
            
            self.channel?.invokeMethod("setRoute", arguments: [
                "route": self.currentRoute,
                "arguments": [:]
            ])
            
            result(true)
        }
    }
    
    private func handleSetupTabs(arguments: Any?, result: @escaping FlutterResult) {
        guard let args = arguments as? [String: Any],
              let tabs = args["tabs"] as? [[String: Any]] else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid tab configuration", details: nil))
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let engine = self.flutterEngine else { return }
            
            let viewControllers = tabs.enumerated().map { [weak self] (index, config) -> UIViewController in
                let flutterVC = FlutterViewController(engine: engine, nibName: nil, bundle: nil)
                let navController = UINavigationController(rootViewController: flutterVC)
                
                if let title = config["title"] as? String,
                   let iconData = config["iconData"] as? FlutterStandardTypedData {
                    self?.configureTabItem(for: navController, title: title, iconData: iconData)
                }
                
                return navController
            }
            
            self.tabBarController?.setViewControllers(viewControllers, animated: false)
            
            if let route = tabs.first?["route"] as? String {
                self.handleRouteChange(route)
            }
            
            result(true)
        }
    }
    
    private func handleUpdateNavigation(arguments: Any?, result: @escaping FlutterResult) {
        guard let args = arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let viewController = self.rootNavigationController?.topViewController else {
                result(false)
                return
            }
            
            if let title = args["title"] as? String {
                viewController.title = title
            }
            
            if let rightButtons = args["rightButtons"] as? [[String: Any]] {
                viewController.navigationItem.rightBarButtonItems = self.createBarButtonItems(from: rightButtons)
            }
            
            if let leftButtons = args["leftButtons"] as? [[String: Any]] {
                viewController.navigationItem.leftBarButtonItems = self.createBarButtonItems(from: leftButtons)
            }
            
            result(true)
        }
    }
    
    private func handleUpdateTheme(arguments: Any?, result: @escaping FlutterResult) {
        guard let args = arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid theme data", details: nil))
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if let navigationController = self.rootNavigationController {
                let style = NavigationStyle(from: args)
                style.apply(to: navigationController.navigationBar)
            }
            
            if let tabBar = self.tabBarController?.tabBar {
                let theme = NavigationTheme()
                theme.apply(to: tabBar)
            }
            
            result(true)
        }
    }
    
    private func configureNavigationItems(for controller: FlutterViewController, with config: [String: Any]) {
        if let rightButtons = config["rightButtons"] as? [[String: Any]] {
            controller.navigationItem.rightBarButtonItems = createBarButtonItems(from: rightButtons)
        }
        
        if let leftButtons = config["leftButtons"] as? [[String: Any]] {
            controller.navigationItem.leftBarButtonItems = createBarButtonItems(from: leftButtons)
        }
    }
    
    private func configureTabItem(for controller: UINavigationController, title: String, iconData: FlutterStandardTypedData) {
        let icon = UIImage(data: iconData.data)?
            .withRenderingMode(.alwaysTemplate)
            .withConfiguration(UIImage.SymbolConfiguration(scale: .large))
        
        controller.tabBarItem = UITabBarItem(
            title: title,
            image: icon,
            selectedImage: icon
        )
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
        DispatchQueue.main.async { [weak self] in
            self?.channel?.invokeMethod("setRoute", arguments: [
                "route": route,
                "arguments": arguments ?? [:]
            ])
        }
    }
}