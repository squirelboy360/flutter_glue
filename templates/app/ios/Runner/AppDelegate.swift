import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    lazy var flutterEngine = FlutterEngine(name: "my_flutter_engine")
    private var modalManager: NativeModalManager! // Keep strong reference
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        flutterEngine.run()
        
        // Register plugins with the root engine
        GeneratedPluginRegistrant.register(with: self)
        
        // Register native text input
        let registrar = flutterEngine.registrar(forPlugin: "native_text_input")
        let factory = NativeTextInputFactory(messenger: flutterEngine.binaryMessenger)
        registrar?.register(factory, withId: "native_text_input")
        
        let controller = window?.rootViewController as! FlutterViewController
        
        // Initialize and store modal manager
        modalManager = NativeModalManager(flutterEngine: flutterEngine)
        modalManager.setupChannel(messenger: controller.binaryMessenger)
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
