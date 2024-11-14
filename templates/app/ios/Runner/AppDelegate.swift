import UIKit
import Flutter

@UIApplicationMain
class AppDelegate: FlutterAppDelegate {
    private var navigationChannel: NavigationChannel?
    private var modalController: ModalController?
    private lazy var flutterEngine: FlutterEngine = {
        let engine = FlutterEngine(name: "main_engine")
        engine.run()
        return engine
    }()
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Initialize Flutter engine
        GeneratedPluginRegistrant.register(with: flutterEngine)
        
        // Create the main Flutter view controller
        let mainFlutterViewController = FlutterViewController(
            engine: flutterEngine,
            nibName: nil,
            bundle: nil
        )
        
        // Create navigation controller for Flutter view
        let navigationController = UINavigationController(rootViewController: mainFlutterViewController)
        
        // Create TabBarController
        let tabController = CustomTabBarController(engine: flutterEngine)
        
        // Configure first tab with Flutter content
        navigationController.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        
        // Create second tab (example)
        let secondViewController = UIViewController()
        let secondNavController = UINavigationController(rootViewController: secondViewController)
        secondNavController.tabBarItem = UITabBarItem(
            title: "Example",
            image: UIImage(systemName: "star"),
            selectedImage: UIImage(systemName: "star.fill")
        )
        
        // Set up tab bar controller
        tabController.viewControllers = [navigationController, secondNavController]
        tabController.delegate = tabController
        
        // Set up navigation channel with tab controller
        navigationChannel = NavigationChannel.shared
        navigationChannel?.setup(with: flutterEngine, controller: mainFlutterViewController, tabController: tabController)
        
        // Set up modal controller
        modalController = ModalController.shared
        modalController?.setup(with: flutterEngine, controller: mainFlutterViewController)
        
        // Configure window
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = tabController
        self.window?.makeKeyAndVisible()
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}