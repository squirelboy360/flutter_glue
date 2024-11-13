import UIKit
import Flutter

@UIApplicationMain
class AppDelegate: FlutterAppDelegate {
    private var navigationChannel: NavigationChannel?
    private var modalController: ModalController?
    private lazy var flutterEngine: FlutterEngine = {
        let engine = FlutterEngine(name: "main_engine")
        engine.run() // Run the engine when it's created
        return engine
    }()

    private var flutterViewController: FlutterViewController?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: flutterEngine)

        // Initialize FlutterViewController with the existing FlutterEngine
        flutterViewController = FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil)
        
        // Set up the root view controller and navigation controller
        let navigationController = UINavigationController(rootViewController: flutterViewController!)
        let tabController = UITabBarController()

        // Set up the Home Tab with the navigation controller
        navigationController.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )

        // Create another example view controller for testing
        let secondViewController = UIViewController()
        let secondNavController = UINavigationController(rootViewController: secondViewController)
        secondNavController.tabBarItem = UITabBarItem(
            title: "Example",
            image: UIImage(systemName: "star"),
            selectedImage: UIImage(systemName: "star.fill")
        )

        // Configure tabs
        tabController.viewControllers = [navigationController, secondNavController]
        tabController.delegate = self

        // Set up channels
        navigationChannel = NavigationChannel.shared
        navigationChannel?.setup(with: flutterEngine, controller: flutterViewController!, tabController: tabController)

        modalController = ModalController.shared
        modalController?.setup(with: flutterEngine, controller: flutterViewController!)

        // Set root view
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = tabController
        self.window?.makeKeyAndVisible()

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    // You no longer need to detach the engine explicitly. Just ensure each view controller uses the engine correctly.
}

extension AppDelegate: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let route = tabBarController.selectedIndex == 0 ? "/" : "/example"
        navigationChannel?.channel?.invokeMethod("setRoute", arguments: ["route": route, "arguments": [:]])
    }
}
