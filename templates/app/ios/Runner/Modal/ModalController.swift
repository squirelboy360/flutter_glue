import Flutter
import UIKit

class ModalController {
    static let shared = ModalController()
    var channel: FlutterMethodChannel?
    
    private var activeModals: [String: (controller: UINavigationController, route: String)] = [:]
    private var modalCounter: Int = 0
    private weak var flutterEngine: FlutterEngine?
    private weak var navigationDelegate: NavigationChannel?
    
    // Keep track of previous route before modal
    private var previousRoute: String = "/"
    
    private init() {}
    
    func setup(with engine: FlutterEngine, controller: FlutterViewController) {
        self.flutterEngine = engine
        self.navigationDelegate = NavigationChannel.shared
        
        channel = FlutterMethodChannel(
            name: "native_modal_channel",
            binaryMessenger: controller.binaryMessenger
        )
        
        setupMethodHandler()
    }
    
    private func setupMethodHandler() {
        channel?.setMethodCallHandler { [weak self] call, result in
            guard let self = self else { return }
            
            switch call.method {
            case "showModal":
                self.handleShowModal(call.arguments) { modalId in
                    result(modalId)
                }
            case "dismissModal":
                self.handleDismissModal(call.arguments) { success in
                    result(success)
                }
            case "dismissAllModals":
                self.handleDismissAllModals() { count in
                    result(["dismissedCount": count])
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
    
    private func handleShowModal(_ arguments: Any?, completion: @escaping (String?) -> Void) {
        guard let args = arguments as? [String: Any],
              let route = args["route"] as? String,
              let engine = flutterEngine else {
            completion(nil)
            return
        }
        
        modalCounter += 1
        let modalId = "modal_\(modalCounter)"
        
        // Store current route before showing modal
        previousRoute = NavigationChannel.shared.currentRoute
        
        // Create Flutter view for modal
        let flutterVC = FlutterViewController(engine: engine, nibName: nil, bundle: nil)
        let navController = UINavigationController(rootViewController: flutterVC)
        
        // Configure modal
        configureModal(navController, with: args)
        
        // Store modal info
        activeModals[modalId] = (navController, route)
        
        // Set route for the modal content
        channel?.invokeMethod("setRoute", arguments: [
            "route": route,
            "arguments": args["arguments"] ?? [:],
            "modalId": modalId
        ])
        
        // Present modal
        DispatchQueue.main.async { [weak self] in
            guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
                completion(nil)
                return
            }
            
            rootViewController.present(navController, animated: true) {
                completion(modalId)
            }
        }
    }
    
    private func handleDismissModal(_ arguments: Any?, completion: @escaping (Bool) -> Void) {
        guard let args = arguments as? [String: Any],
              let modalId = args["modalId"] as? String,
              let modalInfo = activeModals[modalId] else {
            completion(false)
            return
        }
        
        dismissModal(modalInfo.controller, modalId: modalId) { [weak self] success in
            if success {
                // Restore previous route
                self?.navigationDelegate?.handleRouteChange(self?.previousRoute ?? "/")
            }
            completion(success)
        }
    }
    
    private func handleDismissAllModals(completion: @escaping (Int) -> Void) {
        let count = activeModals.count
        let group = DispatchGroup()
        
        for (modalId, modalInfo) in activeModals {
            group.enter()
            dismissModal(modalInfo.controller, modalId: modalId) { _ in
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            // Restore previous route after all modals are dismissed
            self?.navigationDelegate?.handleRouteChange(self?.previousRoute ?? "/")
            completion(count)
        }
    }
    
    private func configureModal(_ controller: UINavigationController, with config: [String: Any]) {
        // Configure presentation style
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
            if let headerTitle = config["headerTitle"] as? String {
                controller.viewControllers.first?.title = headerTitle
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
    
    @objc private func closeModalTapped(_ sender: UIBarButtonItem) {
        guard let modalId = sender.accessibilityIdentifier.map({ "modal_\($0)" }) else { return }
        handleDismissModal(["modalId": modalId]) { _ in }
    }
}
