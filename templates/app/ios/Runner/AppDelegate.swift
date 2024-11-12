import Flutter
import UIKit

@main
class AppDelegate: FlutterAppDelegate {
    lazy var flutterEngine = FlutterEngine(name: "my_flutter_engine")
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        flutterEngine.run()
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
