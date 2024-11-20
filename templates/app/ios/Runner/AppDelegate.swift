import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  lazy var flutterEngine = FlutterEngine(name: "my_flutter_engine")
  lazy var modalEngine = FlutterEngine(name: "my_modal_engine")
  var activeModals: [String: UINavigationController] = [:]
  var modalCounter: Int = 0
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Configure Flutter engines
    flutterEngine.run()
    modalEngine.run()
    GeneratedPluginRegistrant.register(with: flutterEngine)
    GeneratedPluginRegistrant.register(with: modalEngine)

    // Register native text input views for both engines
    let mainFactory = NativeTextInputFactory(messenger: flutterEngine.binaryMessenger)
    let modalFactory = NativeTextInputFactory(messenger: modalEngine.binaryMessenger)
    
    // Register with main engine
    if let registrar = flutterEngine.registrar(forPlugin: "com.example.app/native_text_input") {
        registrar.register(
            mainFactory,
            withId: "com.example.app/native_text_input"
        )
    }
    
    // Register with modal engine
    if let registrar = modalEngine.registrar(forPlugin: "com.example.app/native_text_input") {
        registrar.register(
            modalFactory,
            withId: "com.example.app/native_text_input"
        )
    }

    // Setup modal manager
    let controller = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "native_modal_channel", binaryMessenger: controller.binaryMessenger)
    
    channel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      guard let self = self else { return }
      
      switch call.method {
      case "showModal":
        guard let arguments = call.arguments as? [String: Any],
              let route = arguments["route"] as? String,
              let params = arguments["arguments"] as? [String: String] else {
          result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid route or arguments", details: nil))
          return
        }

        let showHeader = (params["showNativeHeader"] ?? "true").lowercased() == "true"
        let headerTitle = params["headerTitle"]
        let showCloseButton = (params["showCloseButton"] ?? "false").lowercased() == "true"
        
        // Get modal options
        let presentationStyle = (arguments["presentationStyle"] as? String) ?? "sheet"
        let detents = (arguments["detents"] as? [String]) ?? ["large"]
        let isDismissible = (arguments["isDismissible"] as? Bool) ?? true
        let showDragIndicator = (arguments["showDragIndicator"] as? Bool) ?? true
        let enableSwipeGesture = (arguments["enableSwipeGesture"] as? Bool) ?? true
        var backgroundColor: UIColor? = nil
        if let colorValue = arguments["backgroundColor"] as? Int {
          backgroundColor = UIColor(rgb: colorValue)
        }
        
        self.modalCounter += 1
        let modalId = "modal_\(self.modalCounter)"
        
        // Include customization parameters (header style, transition style, etc.)
        let modalConfiguration = ModalConfiguration(from: arguments)

        self.showFlutterModal(
          id: modalId,
          route: route,
          arguments: params,
          showHeader: showHeader,
          headerTitle: headerTitle,
          showCloseButton: showCloseButton,
          presentationStyle: presentationStyle,
          detents: detents,
          isDismissible: isDismissible,
          showDragIndicator: showDragIndicator,
          enableSwipeGesture: enableSwipeGesture,
          backgroundColor: backgroundColor,
          configuration: modalConfiguration
        )
        
        result(modalId)
        
      case "dismissModal":
        guard let arguments = call.arguments as? [String: Any],
              let modalId = arguments["modalId"] as? String else {
          result(FlutterError(code: "INVALID_ARGUMENTS", message: "Modal ID required", details: nil))
          return
        }
        
        if let navController = self.activeModals[modalId] {
          navController.dismiss(animated: true) {
            self.activeModals.removeValue(forKey: modalId)
          }
          result(true)
        } else {
          result(false)
        }
        
      case "dismissAllModals":
        let count = self.activeModals.count
        for (modalId, controller) in self.activeModals {
          controller.dismiss(animated: true) {
            self.activeModals.removeValue(forKey: modalId)
          }
        }
        result(["dismissedCount": count])
        
      case "getActiveModals":
        result(Array(self.activeModals.keys))
        
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func showFlutterModal(
    id: String,
    route: String,
    arguments: [String: String],
    showHeader: Bool,
    headerTitle: String?,
    showCloseButton: Bool,
    presentationStyle: String,
    detents: [String],
    isDismissible: Bool,
    showDragIndicator: Bool,
    enableSwipeGesture: Bool,
    backgroundColor: UIColor?,
    configuration: ModalConfiguration
  ) {
    let flutterViewController = FlutterViewController(engine: modalEngine, nibName: nil, bundle: nil)
    let navController = UINavigationController(rootViewController: flutterViewController)
    
    // Configure modal presentation style
    switch presentationStyle {
      case "fullScreen":
        navController.modalPresentationStyle = .fullScreen
      case "formSheet":
        navController.modalPresentationStyle = .formSheet
      default: // "sheet"
        navController.modalPresentationStyle = .pageSheet
        
        if #available(iOS 15.0, *) {
          let sheet = navController.sheetPresentationController
          
          // Configure detents
          var sheetDetents: [UISheetPresentationController.Detent] = []
          for detent in detents {
            switch detent {
              case "medium":
                sheetDetents.append(.medium())
              default: // "large"
                sheetDetents.append(.large())
            }
          }
          
          sheet?.detents = sheetDetents
          sheet?.prefersGrabberVisible = showDragIndicator
          sheet?.prefersScrollingExpandsWhenScrolledToEdge = true
          sheet?.prefersEdgeAttachedInCompactHeight = true
        }
    }
    
    // Configure modal behavior
    navController.isModalInPresentation = !isDismissible
    
    if let backgroundColor = backgroundColor {
      navController.view.backgroundColor = backgroundColor
    }
    
    activeModals[id] = navController
    
    navController.navigationBar.isHidden = !showHeader
    if showHeader {
      if let title = headerTitle {
        navController.navigationBar.topItem?.title = title
      }
      
      if showCloseButton {
        let closeButton = UIBarButtonItem(
          title: "Close",
          style: .done,
          target: self,
          action: #selector(dismissModal(_:))
        )
        closeButton.tag = Int(id.replacingOccurrences(of: "modal_", with: "")) ?? 0
        navController.navigationBar.topItem?.rightBarButtonItem = closeButton
      }
    }

    if let topController = getTopViewController() {
      topController.present(navController, animated: true, completion: nil)
    }

    let modalChannel = FlutterMethodChannel(
      name: "native_modal_channel",
      binaryMessenger: flutterViewController.binaryMessenger
    )
    modalChannel.invokeMethod("setRoute", arguments: ["route": route, "arguments": arguments])
  }
  
  @objc private func dismissModal(_ sender: UIBarButtonItem) {
    let modalId = "modal_\(sender.tag)"
    if let navController = activeModals[modalId] {
      navController.dismiss(animated: true) { [weak self] in
        self?.activeModals.removeValue(forKey: modalId)
      }
    }
  }
  
  private func getTopViewController() -> UIViewController? {
    var topController = UIApplication.shared.keyWindow?.rootViewController
    
    while let presentedController = topController?.presentedViewController {
      topController = presentedController
    }
    
    return topController
  }
}

extension UIColor {
  convenience init(rgb: Int) {
    self.init(
      red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
      green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
      blue: CGFloat(rgb & 0x0000FF) / 255.0,
      alpha: 1.0
    )
  }
}

struct ModalConfiguration {
  var presentationStyle: String
  var detents: [String]
  var isDismissible: Bool
  var showDragIndicator: Bool
  var enableSwipeGesture: Bool
  var style: ModalStyle
  var transitionStyle: String
  
  // Header style options
  var headerStyle: ModalHeaderStyle?
  
  init(from arguments: [String: Any]) {
    self.presentationStyle = (arguments["presentationStyle"] as? String) ?? "sheet"
    self.detents = (arguments["detents"] as? [String]) ?? ["large"]
    self.isDismissible = (arguments["isDismissible"] as? Bool) ?? true
    self.showDragIndicator = (arguments["showDragIndicator"] as? Bool) ?? true
    self.enableSwipeGesture = (arguments["enableSwipeGesture"] as? Bool) ?? true
    self.style = ModalStyle(from: arguments)
    self.transitionStyle = (arguments["transitionStyle"] as? String) ?? "default"
    self.headerStyle = ModalHeaderStyle(from: arguments)
  }
}

struct ModalStyle {
  var effectiveBackgroundColor: UIColor?
  var barrierColor: UIColor?
  var cornerRadius: CGFloat?
  var blurBackground: Bool
  var blurIntensity: CGFloat?
  
  init(from arguments: [String: Any]) {
    self.effectiveBackgroundColor = UIColor(rgb: arguments["backgroundColor"] as? Int ?? 0xFFFFFF)
    self.barrierColor = UIColor(rgb: arguments["barrierColor"] as? Int ?? 0x000000)
    self.cornerRadius = (arguments["cornerRadius"] as? CGFloat) ?? 20.0
    self.blurBackground = (arguments["blurBackground"] as? Bool) ?? false
    self.blurIntensity = (arguments["blurIntensity"] as? CGFloat) ?? 5.0
  }
}

struct ModalHeaderStyle {
  var backgroundColor: UIColor?
  var height: CGFloat
  var dividerColor: UIColor?
  
  init(from arguments: [String: Any]) {
    self.backgroundColor = UIColor(rgb: arguments["headerBackgroundColor"] as? Int ?? 0xF0F0F0)
    self.height = (arguments["headerHeight"] as? CGFloat) ?? 60.0
    self.dividerColor = UIColor(rgb: arguments["headerDividerColor"] as? Int ?? 0xCCCCCC)
  }
}
