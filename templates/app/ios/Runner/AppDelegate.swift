import Flutter
import UIKit

@main
class AppDelegate: FlutterAppDelegate {
    private var flutterEngine: FlutterEngine?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Initialize Flutter engine
        flutterEngine = FlutterEngine(name: "my_flutter_engine")
        flutterEngine?.run()
        
        // Ensure the flutterEngine is non-nil before continuing
        guard let flutterEngine = flutterEngine else {
            fatalError("Failed to initialize FlutterEngine")
        }

        GeneratedPluginRegistrant.register(with: self)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        let flutterViewController = FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil)
        let navigationController = UINavigationController(rootViewController: flutterViewController)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        // Setup Navigation and Modal
        NavigationChannel.shared.setup(with: flutterEngine, controller: flutterViewController)
        ModalController.shared.setup(with: flutterEngine, controller: flutterViewController)

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
