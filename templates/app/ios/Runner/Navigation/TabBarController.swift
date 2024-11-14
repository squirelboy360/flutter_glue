import Flutter
import UIKit

class CustomTabBarController: UITabBarController {
    private let flutterEngine: FlutterEngine
    private var currentRoute: String = "/"
    
    init(engine: FlutterEngine) {
        self.flutterEngine = engine
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        delegate = self
    }
    
    private func setupAppearance() {
        tabBar.isTranslucent = true
        tabBar.backgroundColor = .systemBackground
        
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .systemBackground
            
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        }
    }
    
    func configureTabs(with tabConfigs: [[String: Any]]) {
        // Detach engine from current VC if exists
        if let currentVC = flutterEngine.viewController {
            currentVC.removeFromParent()
            currentVC.view.removeFromSuperview()
            flutterEngine.viewController = nil
        }
        
        let viewControllers = tabConfigs.enumerated().map { [weak self] (index, config) -> UIViewController in
            guard let self = self else { return UIViewController() }
            
            let flutterVC = FlutterViewController(engine: self.flutterEngine, nibName: nil, bundle: nil)
            let navController = UINavigationController(rootViewController: flutterVC)
            
            // Configure tab appearance
            if let title = config["title"] as? String {
                if let iconData = config["iconData"] as? FlutterStandardTypedData {
                    configureTabItem(for: navController, title: title, iconData: iconData)
                } else {
                    // Fallback to system icons if no custom icons provided
                    let defaultIcon = index == 0 ? "house" : "star"
                    let defaultSelectedIcon = index == 0 ? "house.fill" : "star.fill"
                    navController.tabBarItem = UITabBarItem(
                        title: title,
                        image: UIImage(systemName: defaultIcon),
                        selectedImage: UIImage(systemName: defaultSelectedIcon)
                    )
                }
            }
            
            // Configure navigation bar if needed
            if let navStyle = config["navigationStyle"] as? [String: Any] {
                configureNavigationBar(navController.navigationBar, with: navStyle)
            }
            
            return navController
        }
        
        setViewControllers(viewControllers, animated: false)
        selectedIndex = 0
        
        // Set initial route
        if let route = tabConfigs.first?["route"] as? String {
            NavigationChannel.shared.handleRouteChange(route)
        }
    }
    
    private func configureTabItem(for controller: UINavigationController, title: String, iconData: FlutterStandardTypedData) {
        if let icon = UIImage(data: iconData.data) {
            let configuredIcon = icon
                .withRenderingMode(.alwaysTemplate)
                .withConfiguration(UIImage.SymbolConfiguration(scale: .large))
            
            controller.tabBarItem = UITabBarItem(
                title: title,
                image: configuredIcon,
                selectedImage: configuredIcon
            )
        }
    }
    
    private func configureNavigationBar(_ navigationBar: UINavigationBar, with style: [String: Any]) {
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            
            if let backgroundColor = style["backgroundColor"] as? Int {
                appearance.backgroundColor = UIColor(
                    red: CGFloat((backgroundColor >> 16) & 0xFF) / 255.0,
                    green: CGFloat((backgroundColor >> 8) & 0xFF) / 255.0,
                    blue: CGFloat(backgroundColor & 0xFF) / 255.0,
                    alpha: CGFloat((backgroundColor >> 24) & 0xFF) / 255.0
                )
            }
            
            if let titleColor = style["titleColor"] as? Int {
                appearance.titleTextAttributes = [
                    .foregroundColor: UIColor(
                        red: CGFloat((titleColor >> 16) & 0xFF) / 255.0,
                        green: CGFloat((titleColor >> 8) & 0xFF) / 255.0,
                        blue: CGFloat(titleColor & 0xFF) / 255.0,
                        alpha: CGFloat((titleColor >> 24) & 0xFF) / 255.0
                    )
                ]
            }
            
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
            navigationBar.compactAppearance = appearance
        }
    }
}

extension CustomTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard let navController = viewController as? UINavigationController else { return }
        
        // Reset navigation stack when switching tabs
        if navController.viewControllers.count > 1 {
            navController.popToRootViewController(animated: false)
        }
        
        // Update Flutter route based on selected tab
        let route = selectedIndex == 0 ? "/" : "/example"
        currentRoute = route
        NavigationChannel.shared.handleRouteChange(route)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        // Detach engine before switching tabs
        if let navController = viewController as? UINavigationController {
            flutterEngine.viewController = nil
            navController.popToRootViewController(animated: false)
        }
        return true
    }
}