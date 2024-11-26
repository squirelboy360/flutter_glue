import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  lazy var flutterEngine = FlutterEngine(name: "my_flutter_engine")
  lazy var modalEngine = FlutterEngine(name: "my_modal_engine")
  var activeModals: [String: UINavigationController] = [:]
  var modalConfigs: [String: ModalConfiguration] = [:]
  var sheetDelegates: [String: UISheetPresentationController] = [:]
  var activeEngines: [String: FlutterEngine] = [:]
  var modalCounter: Int = 0
  private var modalConfigurations: [String: ModalConfiguration] = [:]
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Configure Flutter engines
    flutterEngine.run()
    modalEngine.run()
    
    // Register plugins with both engines
    GeneratedPluginRegistrant.register(with: flutterEngine)
    GeneratedPluginRegistrant.register(with: modalEngine)
    
    // Register native text input views for both engines
    let viewId = "com.example.app/native_text_input"
    let mainFactory = NativeTextInputFactory(messenger: flutterEngine.binaryMessenger)
    let modalFactory = NativeTextInputFactory(messenger: modalEngine.binaryMessenger)
    
    // Register with main engine
    let registrar = flutterEngine.registrar(forPlugin: viewId)
    registrar?.register(mainFactory, withId: viewId)
    
    // Register with modal engine
    let modalRegistrar = modalEngine.registrar(forPlugin: viewId)
    modalRegistrar?.register(modalFactory, withId: viewId)
    
    // Setup keyboard dismissal channel for both engines
    let mainKeyboardChannel = FlutterMethodChannel(
      name: "com.example.app/keyboard",
      binaryMessenger: flutterEngine.binaryMessenger
    )
    
    let modalKeyboardChannel = FlutterMethodChannel(
      name: "com.example.app/keyboard",
      binaryMessenger: modalEngine.binaryMessenger
    )
    
    let keyboardHandler: FlutterMethodCallHandler = { [weak self] call, result in
      if call.method == "dismissKeyboard" {
        self?.window?.endEditing(true)
        result(nil)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
    
    mainKeyboardChannel.setMethodCallHandler(keyboardHandler)
    modalKeyboardChannel.setMethodCallHandler(keyboardHandler)

    // Set the root view controller
    self.window = UIWindow(frame: UIScreen.main.bounds)
    let viewController = FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil)
    self.window.rootViewController = viewController
    self.window.makeKeyAndVisible()
    
    // Setup modal manager for both engines
    let mainModalChannel = FlutterMethodChannel(name: "native_modal_channel", binaryMessenger: viewController.binaryMessenger)
    let modalModalChannel = FlutterMethodChannel(name: "native_modal_channel", binaryMessenger: modalEngine.binaryMessenger)
    
    let modalHandler: FlutterMethodCallHandler = { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      guard let self = self else { return }
      
      switch call.method {
      case "showModal":
        guard let arguments = call.arguments as? [String: Any],
              let route = arguments["route"] as? String,
              let modalId = arguments["modalId"] as? String else {
          result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing required arguments", details: nil))
          return
        }
        
        let showHeader = arguments["showNativeHeader"] as? Bool ?? true
        let showCloseButton = arguments["showCloseButton"] as? Bool ?? true
        let headerTitle = arguments["headerTitle"] as? String
        let modalArgs = (arguments["arguments"] as? [String: String]) ?? [:]
        let configuration = ModalConfiguration(from: arguments)
        
        self.showFlutterModal(
          id: modalId,
          route: route,
          arguments: modalArgs,
          showHeader: showHeader,
          headerTitle: headerTitle,
          showCloseButton: showCloseButton,
          configuration: configuration
        )
        
        result(modalId)
        
      case "updateModalConfiguration":
        guard let arguments = call.arguments as? [String: Any],
              let modalId = arguments["modalId"] as? String else {
          result(false)
          return
        }
        
        self.updateModalConfiguration(modalId, with: arguments)
        result(true)
        
      case "dismissModal":
        guard let arguments = call.arguments as? [String: Any],
              let modalId = arguments["modalId"] as? String,
              let navController = self.activeModals[modalId] else {
          result(false)
          return
        }
        
        navController.dismiss(animated: true) {
          self.activeModals.removeValue(forKey: modalId)
          self.modalConfigs.removeValue(forKey: modalId)
          self.sheetDelegates.removeValue(forKey: modalId)
          result(true)
        }
        
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    
    mainModalChannel.setMethodCallHandler(modalHandler)
    modalModalChannel.setMethodCallHandler(modalHandler)
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func showFlutterModal(
    id: String,
    route: String,
    arguments: [String: String],
    showHeader: Bool,
    headerTitle: String?,
    showCloseButton: Bool,
    configuration: ModalConfiguration
  ) {
    let flutterViewController = FlutterViewController(engine: modalEngine, nibName: nil, bundle: nil)
    let navController = UINavigationController(rootViewController: flutterViewController)
    
    // Store modal and configuration
    activeModals[id] = navController
    modalConfigs[id] = configuration
    
    // Configure presentation style
    switch configuration.presentationStyle {
      case "fullScreen":
        navController.modalPresentationStyle = .fullScreen
      case "formSheet":
        navController.modalPresentationStyle = .formSheet
      default:
        navController.modalPresentationStyle = .pageSheet
        
        if #available(iOS 15.0, *), let sheet = navController.sheetPresentationController {
          sheetDelegates[id] = sheet
          
          // Configure detents
          var detents: [UISheetPresentationController.Detent] = []
          for detent in configuration.detents {
            switch detent {
              case "small":
                if #available(iOS 16.0, *) {
                  detents.append(.custom { _ in return UIScreen.main.bounds.height * 0.3 })
                }
              case "medium":
                detents.append(.medium())
              case "large":
                detents.append(.large())
              default:
                detents.append(.large())
            }
          }
          sheet.detents = detents
          
          // Set initial detent
          if #available(iOS 16.0, *), let selectedDetent = configuration.selectedDetent {
            sheet.selectedDetentIdentifier = .init(selectedDetent)
          }
          
          sheet.prefersGrabberVisible = configuration.showDragIndicator
          sheet.prefersScrollingExpandsWhenScrolledToEdge = true
          sheet.prefersEdgeAttachedInCompactHeight = true
        }
    }
    
    // Configure header
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
    
    // Set background color and corner radius
    if let backgroundColor = configuration.backgroundColor {
      navController.view.backgroundColor = backgroundColor
    }
    if let cornerRadius = configuration.cornerRadius {
      navController.view.layer.cornerRadius = cornerRadius
      navController.view.clipsToBounds = true
    }
    
    // Present modal
    if let topController = getTopViewController() {
      topController.present(navController, animated: true, completion: nil)
      
      // Set up route
      let modalChannel = FlutterMethodChannel(
        name: "native_modal_channel",
        binaryMessenger: flutterViewController.binaryMessenger
      )
      modalChannel.invokeMethod("setRoute", arguments: ["route": route, "arguments": arguments])
    }
  }
  
  private func updateModalConfiguration(_ modalId: String, with updates: [String: Any]) {
    guard let navController = activeModals[modalId] else {
      debugPrint("[Native] No modal found for ID: \(modalId)")
      return
    }
    
    // Create new configuration from updates
    let newConfig = ModalConfiguration(from: updates)
    modalConfigs[modalId] = newConfig
    
    if #available(iOS 15.0, *), let sheet = sheetDelegates[modalId] {
      // Update detents
      var detents: [UISheetPresentationController.Detent] = []
      for detent in newConfig.detents {
        switch detent {
          case "small":
            if #available(iOS 16.0, *) {
              detents.append(.custom { _ in return UIScreen.main.bounds.height * 0.3 })
            }
          case "medium":
            detents.append(.medium())
          case "large":
            detents.append(.large())
          default:
            detents.append(.large())
        }
      }
      
      UIView.animate(withDuration: 0.3) {
        sheet.animateChanges {
          sheet.detents = detents
          if #available(iOS 16.0, *), let selectedDetent = newConfig.selectedDetent {
            sheet.selectedDetentIdentifier = .init(selectedDetent)
          }
          sheet.prefersGrabberVisible = newConfig.showDragIndicator
        }
      }
    }
    
    // Update presentation style
    switch newConfig.presentationStyle {
      case "fullScreen":
        navController.modalPresentationStyle = .fullScreen
      case "formSheet":
        navController.modalPresentationStyle = .formSheet
      default:
        navController.modalPresentationStyle = .pageSheet
    }
    
    // Update background and corner radius
    if let backgroundColor = newConfig.backgroundColor {
      navController.view.backgroundColor = backgroundColor
    }
    if let cornerRadius = newConfig.cornerRadius {
      navController.view.layer.cornerRadius = cornerRadius
      navController.view.clipsToBounds = true
    }
    
    // Update header configuration
    let showHeader = updates["showNativeHeader"] as? Bool ?? true
    let showCloseButton = updates["showCloseButton"] as? Bool ?? true
    let headerTitle = updates["headerTitle"] as? String
    
    navController.navigationBar.isHidden = !showHeader
    if showHeader {
      if let title = headerTitle {
        navController.navigationBar.topItem?.title = title
      }
      
      if showCloseButton {
        if navController.navigationBar.topItem?.rightBarButtonItem == nil {
          let closeButton = UIBarButtonItem(
            title: "Close",
            style: .done,
            target: self,
            action: #selector(dismissModal(_:))
          )
          closeButton.tag = Int(modalId.replacingOccurrences(of: "modal_", with: "")) ?? 0
          navController.navigationBar.topItem?.rightBarButtonItem = closeButton
        }
      } else {
        navController.navigationBar.topItem?.rightBarButtonItem = nil
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
  
  @objc private func dismissModal(_ sender: UIBarButtonItem) {
    let modalId = "modal_\(sender.tag)"
    if let navController = activeModals[modalId] {
      navController.dismiss(animated: true) {
        self.activeModals.removeValue(forKey: modalId)
        self.modalConfigs.removeValue(forKey: modalId)
        self.sheetDelegates.removeValue(forKey: modalId)
      }
    }
  }
}

extension UIColor {
  convenience init(rgb: Int) {
    self.init(
      red: CGFloat((rgb >> 16) & 0xFF) / 255.0,
      green: CGFloat((rgb >> 8) & 0xFF) / 255.0,
      blue: CGFloat(rgb & 0xFF) / 255.0,
      alpha: 1.0
    )
  }
}

struct ModalConfiguration {
  let presentationStyle: String
  let detents: [String]
  let selectedDetent: String?
  let isDismissible: Bool
  let showDragIndicator: Bool
  let enableSwipeGesture: Bool
  let cornerRadius: CGFloat?
  let backgroundColor: UIColor?
  let headerStyle: [String: Any]?
  
  init(from arguments: [String: Any]) {
    self.presentationStyle = arguments["presentationStyle"] as? String ?? "sheet"
    self.detents = arguments["detents"] as? [String] ?? ["medium"]
    self.selectedDetent = arguments["selectedDetentIdentifier"] as? String
    self.isDismissible = arguments["isDismissible"] as? Bool ?? true
    self.showDragIndicator = arguments["showDragIndicator"] as? Bool ?? true
    self.enableSwipeGesture = arguments["enableSwipeGesture"] as? Bool ?? true
    self.cornerRadius = arguments["cornerRadius"] as? CGFloat
    
    if let colorString = arguments["backgroundColor"] as? String,
       let colorValue = Int(colorString, radix: 16) {
      self.backgroundColor = UIColor(rgb: colorValue)
    } else {
      self.backgroundColor = nil
    }
    
    self.headerStyle = arguments["headerStyle"] as? [String: Any]
  }
}

struct ModalStyle {
  var effectiveBackgroundColor: UIColor?
  var barrierColor: UIColor?
  var cornerRadius: CGFloat?
  var blurBackground: Bool
  var blurIntensity: CGFloat?
  var customDetentHeight: CGFloat?
  var initialDetent: Int?
  var selectedDetentIdentifier: String?
  
  init(from arguments: [String: Any]) {
    self.effectiveBackgroundColor = UIColor(rgb: arguments["backgroundColor"] as? Int ?? 0xFFFFFF)
    self.barrierColor = UIColor(rgb: arguments["barrierColor"] as? Int ?? 0x000000)
    self.cornerRadius = (arguments["cornerRadius"] as? CGFloat) ?? 20.0
    self.blurBackground = (arguments["blurBackground"] as? Bool) ?? false
    self.blurIntensity = (arguments["blurIntensity"] as? CGFloat) ?? 5.0
    self.customDetentHeight = (arguments["customDetentHeight"] as? CGFloat)
    self.initialDetent = (arguments["selectedDetentIdentifier"] as? Int)
    self.selectedDetentIdentifier = (arguments["selectedDetentIdentifier"] as? String)
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
