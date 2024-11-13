import Flutter
import UIKit

class TabBarController: UITabBarController {
    private let flutterEngine: FlutterEngine
    weak var navigationDelegate: NavigationChannel?
    private var routeConfiguration: [Int: String] = [:]
    
    init(engine: FlutterEngine) {
        self.flutterEngine = engine
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureTabs(with tabConfigs: [[String: Any]]) {
        var viewControllers: [UIViewController] = []
        
        for (index, config) in tabConfigs.enumerated() {
            if let route = config["route"] as? String {
                routeConfiguration[index] = route
            }
            
            let flutterVC = FlutterViewController(
                engine: flutterEngine,
                nibName: nil,
                bundle: nil
            )
            
            let navController = UINavigationController(rootViewController: flutterVC)
            
            // Configure navigation bar appearance if provided
            if let navStyle = config["navigationStyle"] as? [String: Any] {
                configureNavigationBar(navController.navigationBar, with: navStyle)
            }
            
            // Configure tab appearance
            configureTabItem(for: navController, with: config)
            
            viewControllers.append(navController)
        }
        
        self.viewControllers = viewControllers
        self.selectedIndex = 0
        self.delegate = self
        
        // Set initial route
        if let initialRoute = routeConfiguration[0] {
            navigationDelegate?.handleRouteChange(initialRoute)
        }
    }
    
    private func configureTabItem(for controller: UINavigationController, with config: [String: Any]) {
        // Extract tab configuration
        let title = config["title"] as? String
        
        if let iconData = config["iconData"] as? [String: Any] {
            // Handle different types of icon data
            if let imageData = iconData["data"] as? FlutterStandardTypedData {
                // Direct image data
                let icon = UIImage(data: imageData.data)?.withRenderingMode(.alwaysTemplate)
                let selectedIcon = config["selectedIconData"].flatMap {
                    ($0 as? FlutterStandardTypedData).flatMap {
                        UIImage(data: $0.data)?.withRenderingMode(.alwaysTemplate)
                    }
                }
                
                controller.tabBarItem = UITabBarItem(
                    title: title,
                    image: icon,
                    selectedImage: selectedIcon
                )
            } else if let systemName = iconData["systemName"] as? String {
                // System icon name
                controller.tabBarItem = UITabBarItem(
                    title: title,
                    image: UIImage(systemName: systemName),
                    selectedImage: UIImage(systemName: (iconData["selectedSystemName"] as? String) ?? systemName)
                )
            }
        }
    }
    
    private func configureNavigationBar(_ navigationBar: UINavigationBar, with style: [String: Any]) {
        if let backgroundColor = style["backgroundColor"] as? Int {
            let color = UIColor(
                red: CGFloat((backgroundColor >> 16) & 0xFF) / 255.0,
                green: CGFloat((backgroundColor >> 8) & 0xFF) / 255.0,
                blue: CGFloat(backgroundColor & 0xFF) / 255.0,
                alpha: CGFloat((backgroundColor >> 24) & 0xFF) / 255.0
            )
            navigationBar.backgroundColor = color
        }
        
        if let isTranslucent = style["isTranslucent"] as? Bool {
            navigationBar.isTranslucent = isTranslucent
        }
        
        // Configure other styling as needed
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        
        if let titleColor = style["titleColor"] as? Int {
            let color = UIColor(
                red: CGFloat((titleColor >> 16) & 0xFF) / 255.0,
                green: CGFloat((titleColor >> 8) & 0xFF) / 255.0,
                blue: CGFloat(titleColor & 0xFF) / 255.0,
                alpha: CGFloat((titleColor >> 24) & 0xFF) / 255.0
            )
            appearance.titleTextAttributes = [.foregroundColor: color]
        }
        
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        if #available(iOS 15.0, *) {
            navigationBar.compactScrollEdgeAppearance = appearance
        }
    }
}

extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard let route = routeConfiguration[selectedIndex] else { return }
        
        // Notify navigation channel of tab change
        navigationDelegate?.handleRouteChange(route)
    }
}
