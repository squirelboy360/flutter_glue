import Flutter
import UIKit

class ModalController {
    static let shared = ModalController()
    var channel: FlutterMethodChannel?
    
    private var activeModals: [String: (controller: UINavigationController, route: String)] = [:]
    private var modalCounter: Int = 0
    private weak var flutterEngine: FlutterEngine?
    private var previousRoute: String = "/"
    
    private init() {}
    
    func setup(with engine: FlutterEngine, controller: FlutterViewController) {
        self.flutterEngine = engine
        
        channel = FlutterMethodChannel(
            name: "native_modal_channel",
            binaryMessenger: controller.binaryMessenger
        )
        
        channel?.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            guard let self = self else { return }
            
            switch call.method {
            case "showModal":
                self.handleShowModal(arguments: call.arguments, result: result)
            case "dismissModal":
                self.handleDismissModal(arguments: call.arguments, result: result)
            case "dismissAllModals":
                self.handleDismissAllModals(result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
    
    private func handleShowModal(arguments: Any?, result: @escaping FlutterResult) {
        guard let args = arguments as? [String: Any],
              let route = args["route"] as? String,
              let engine = flutterEngine else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments or missing engine", details: nil))
            return
        }
        
        modalCounter += 1
        let modalId = "modal_\(modalCounter)"
        
        // Store current route before showing modal
        previousRoute = NavigationChannel.shared.currentRoute
        
        // Before creating new VC, detach engine
        engine.viewController = nil
        
        let flutterVC = FlutterViewController(engine: engine, nibName: nil, bundle: nil)
        let navController = UINavigationController(rootViewController: flutterVC)
        
        configureModal(navController, with: args)
        activeModals[modalId] = (navController, route)
        
        // Set route for modal content
        channel?.invokeMethod("setRoute", arguments: [
            "route": route,
            "arguments": args["arguments"] ?? [:],
            "modalId": modalId
        ])
        
        DispatchQueue.main.async { [weak self] in
            guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
                result(nil)
                return
            }
            
            rootViewController.present(navController, animated: true) {
                result(modalId)
            }
        }
    }
    
    private func handleDismissModal(arguments: Any?, result: @escaping FlutterResult) {
        guard let args = arguments as? [String: Any],
              let modalId = args["modalId"] as? String,
              let modalInfo = activeModals[modalId] else {
            result(false)
            return
        }
        
        dismissModal(modalInfo.controller, modalId: modalId) { [weak self] success in
            if success {
                self?.restorePreviousRoute()
            }
            result(success)
        }
    }
    
    private func handleDismissAllModals(result: @escaping FlutterResult) {
        let count = activeModals.count
        let group = DispatchGroup()
        
        for (modalId, modalInfo) in activeModals {
            group.enter()
            dismissModal(modalInfo.controller, modalId: modalId) { _ in
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.restorePreviousRoute()
            result(["dismissedCount": count])
        }
    }
    
    private func configureModal(_ controller: UINavigationController, with config: [String: Any]) {
        // Set presentation style
        if let style = config["presentationStyle"] as? String {
            switch style {
            case "fullScreen":
                controller.modalPresentationStyle = .fullScreen
            case "formSheet":
                controller.modalPresentationStyle = .formSheet
            default:
                controller.modalPresentationStyle = .pageSheet
                if #available(iOS 15.0, *) {
                    configureSheet(controller.sheetPresentationController, with: config)
                }
            }
        }
        
        // Configure dismissibility
        if let isDismissible = config["isDismissible"] as? Bool {
            controller.isModalInPresentation = !isDismissible
        }
        
        // Configure navigation bar
        if let showHeader = config["showHeader"] as? Bool, showHeader {
            if let title = config["headerTitle"] as? String {
                controller.viewControllers.first?.title = title
            }
            
            if let showCloseButton = config["showCloseButton"] as? Bool,
               showCloseButton,
               let flutterVC = controller.viewControllers.first {
                let closeButton = UIBarButtonItem(
                    title: "Close",
                    style: .done,
                    target: self,
                    action: #selector(closeModalTapped(_:))
                )
                closeButton.accessibilityIdentifier = String(modalCounter)
                flutterVC.navigationItem.rightBarButtonItem = closeButton
            }
        } else {
            controller.navigationBar.isHidden = true
        }
    }
    
    @available(iOS 15.0, *)
    private func configureSheet(_ sheet: UISheetPresentationController?, with config: [String: Any]) {
        guard let sheet = sheet else { return }
        
        if let detents = config["detents"] as? [String] {
            sheet.detents = detents.compactMap { detent in
                switch detent {
                case "medium": return .medium()
                case "large": return .large()
                default: return nil
                }
            }
        }
        
        if let showDragIndicator = config["showDragIndicator"] as? Bool {
            sheet.prefersGrabberVisible = showDragIndicator
        }
    }
    
    private func dismissModal(
        _ controller: UINavigationController,
        modalId: String,
        completion: @escaping (Bool) -> Void
    ) {
        DispatchQueue.main.async {
            controller.dismiss(animated: true) { [weak self] in
                self?.activeModals.removeValue(forKey: modalId)
                completion(true)
            }
        }
    }
    
    private func restorePreviousRoute() {
        if let engine = flutterEngine {
            engine.viewController = nil
            channel?.invokeMethod("setRoute", arguments: [
                "route": previousRoute,
                "arguments": [:]
            ])
        }
    }
    
    @objc private func closeModalTapped(_ sender: UIBarButtonItem) {
        guard let modalId = sender.accessibilityIdentifier.map({ "modal_\($0)" }) else { return }
        handleDismissModal(arguments: ["modalId": modalId], result: { _ in })
    }
}