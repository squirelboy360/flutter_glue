import Flutter
import UIKit

class TabBarController: UITabBarController {
    private let flutterEngine: FlutterEngine
    private weak var channel: FlutterMethodChannel?
    
    init(engine: FlutterEngine) {
        self.flutterEngine = engine
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureTabs(with tabConfigs: [[String: Any]]) {
        var viewControllers: [UIViewController] = []
        
        // Create a single FlutterViewController that will be shared
        let flutterViewController = FlutterViewController(
            engine: flutterEngine,
            nibName: nil,
            bundle: nil
        )
        
        // Wrap it in a navigation controller
        let mainNavController = UINavigationController(rootViewController: flutterViewController)
        
        // Configure the first tab
        if let firstTab = tabConfigs.first,
           let title = firstTab["title"] as? String {
            mainNavController.tabBarItem = UITabBarItem(
                title: title,
                image: UIImage(systemName: "circle"),
                selectedImage: UIImage(systemName: "circle.fill")
            )
        }
        
        viewControllers.append(mainNavController)
        
        // Add additional tabs if needed (they will share the same Flutter engine)
        for (index, config) in tabConfigs.enumerated() where index > 0 {
            if let title = config["title"] as? String {
                // Create a placeholder view controller for additional tabs
                let additionalVC = UIViewController()
                additionalVC.tabBarItem = UITabBarItem(
                    title: title,
                    image: UIImage(systemName: "circle"),
                    selectedImage: UIImage(systemName: "circle.fill")
                )
                viewControllers.append(additionalVC)
            }
        }
        
        self.viewControllers = viewControllers
        self.selectedIndex = 0
        self.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.isTranslucent = true
        tabBar.backgroundColor = .systemBackground
    }
}

extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let route = selectedIndex == 0 ? "/" : "/example"
        
        // Get the channel from NavigationChannel since it's properly set up there
        NavigationChannel.shared.channel?.invokeMethod(
            "setRoute",
            arguments: ["route": route, "arguments": [:]]
        )
    }
}
