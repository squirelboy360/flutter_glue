import UIKit
import Flutter

@UIApplicationMain
class AppDelegate: FlutterAppDelegate {
    private var navigationChannel: NavigationChannel?
    private var modalController: ModalController?
    private var navigationCoordinator: NavigationCoordinator?
    
    // Single engine instance maintained throughout app lifecycle
    private lazy var flutterEngine: FlutterEngine = {
        let engine = FlutterEngine(name: "main_engine")
        engine.run()
        return engine
    }()
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Register plugins once
        GeneratedPluginRegistrant.register(with: flutterEngine)
        
        // Create main Flutter view controller
        let mainFlutterViewController = FlutterViewController(
            engine: flutterEngine,
            nibName: nil,
            bundle: nil
        )
        
        // Create root navigation controller
        let navigationController = UINavigationController(rootViewController: mainFlutterViewController)
        
        // Create and configure tab controller
        let tabController = UITabBarController()
        tabController.viewControllers = [navigationController]
        tabController.delegate = self
        
        // Set up navigation channel first (it's our main coordinator)
        navigationChannel = NavigationChannel.shared
        navigationChannel?.setup(with: flutterEngine, controller: mainFlutterViewController, tabController: tabController)
        
        // Set up navigation coordinator
        navigationCoordinator = NavigationCoordinator(
            navigationController: navigationController,
            flutterEngine: flutterEngine,
            navigationDelegate: navigationChannel!
        )
        
        // Set up modal controller last
        modalController = ModalController.shared
        modalController?.setup(with: flutterEngine, controller: mainFlutterViewController)
        
        // Configure window
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = tabController
        self.window?.makeKeyAndVisible()
        
        // Set up hot reload observer
        setupHotReloadSupport()
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func setupHotReloadSupport() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("flutter/hotReload"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleHotReload()
        }
    }
    
    private func handleHotReload() {
        // Notify channel to refresh current route
        navigationChannel?.refreshCurrentRoute()
        
        // Let modal controller handle its own hot reload
        // (It's already set up with hot reload support)
    }
}

// MARK: - UITabBarControllerDelegate
extension AppDelegate: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard let navController = viewController as? UINavigationController,
              let flutterVC = navController.viewControllers.first as? FlutterViewController else {
            return
        }
        
        // Let navigation channel handle tab change
        let route = tabBarController.selectedIndex == 0 ? "/" : "/example"
        navigationChannel?.handleRouteChange(route)
    }
}
