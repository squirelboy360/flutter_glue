import Flutter
import UIKit

class ModalController {
    static let shared = ModalController()
    
    // Change channel to internal access
    var channel: FlutterMethodChannel?
    
    private var activeModals: [String: UINavigationController] = [:]
    private var modalCounter: Int = 0
    private weak var flutterEngine: FlutterEngine?
    private weak var mainFlutterViewController: FlutterViewController?
    
    private init() {}
    
    func setup(with engine: FlutterEngine, controller: FlutterViewController) {
        self.flutterEngine = engine
        self.mainFlutterViewController = controller
        
        channel = FlutterMethodChannel(
            name: "native_modal_channel",
            binaryMessenger: controller.binaryMessenger
        )
        
        channel?.setMethodCallHandler { [weak self] call, result in
            guard let self = self else { return }
            
            switch call.method {
            case "showModal":
                guard let arguments = call.arguments as? [String: Any],
                      let route = arguments["route"] as? String,
                      let params = arguments["arguments"] as? [String: String] else {
                    result(FlutterError(code: "INVALID_ARGUMENTS",
                                      message: "Invalid route or arguments",
                                      details: nil))
                    return
                }
                
                let configuration = ModalConfiguration(from: arguments)
                self.showModal(route: route, arguments: params, config: configuration) { modalId in
                    result(modalId)
                }
                
            case "dismissModal":
                guard let arguments = call.arguments as? [String: Any],
                      let modalId = arguments["modalId"] as? String else {
                    result(FlutterError(code: "INVALID_ARGUMENTS",
                                      message: "Modal ID required",
                                      details: nil))
                    return
                }
                
                self.dismissModal(modalId: modalId) { success in
                    result(success)
                }
                
            case "dismissAllModals":
                let count = self.dismissAllModals()
                result(["dismissedCount": count])
                
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
    
    private func showModal(
        route: String,
        arguments: [String: String],
        config: ModalConfiguration,
        completion: @escaping (String) -> Void
    ) {
        guard let flutterEngine = self.flutterEngine else { return }
        
        modalCounter += 1
        let modalId = "modal_\(modalCounter)"
        
        let flutterViewController = FlutterViewController(
            engine: flutterEngine,
            nibName: nil,
            bundle: nil
        )
        
        let navController = UINavigationController(rootViewController: flutterViewController)
        activeModals[modalId] = navController
        
        // Configure modal presentation
        switch config.presentationStyle {
        case "fullScreen":
            navController.modalPresentationStyle = .fullScreen
        case "formSheet":
            navController.modalPresentationStyle = .formSheet
        default:
            navController.modalPresentationStyle = .pageSheet
            if #available(iOS 15.0, *) {
                if let sheet = navController.sheetPresentationController {
                    var detents: [UISheetPresentationController.Detent] = []
                    for detent in config.detents {
                        switch detent {
                        case "medium":
                            detents.append(.medium())
                        default:
                            detents.append(.large())
                        }
                    }
                    sheet.detents = detents
                    sheet.prefersGrabberVisible = config.showDragIndicator
                }
            }
        }
        
        navController.isModalInPresentation = !config.isDismissible
        
        // Configure appearance
        if let backgroundColor = config.style.backgroundColor {
            navController.view.backgroundColor = backgroundColor
        }
        
        // Configure navigation bar
        navController.navigationBar.isHidden = !config.showHeader
        if config.showHeader {
            flutterViewController.title = config.headerTitle
            
            if config.showCloseButton {
                let closeButton = UIBarButtonItem(
                    title: "Close",
                    style: .done,
                    target: self,
                    action: #selector(closeModalTapped(_:))
                )
                closeButton.accessibilityIdentifier = modalId
                flutterViewController.navigationItem.rightBarButtonItem = closeButton
            }
        }
        
        // Set route before presenting
        channel?.invokeMethod("setRoute", arguments: [
            "route": route,
            "arguments": arguments
        ])
        
        // Present the modal
        DispatchQueue.main.async { [weak self] in
            guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
                return
            }
            
            rootViewController.present(navController, animated: true) {
                completion(modalId)
            }
        }
    }
    
    @objc private func closeModalTapped(_ sender: UIBarButtonItem) {
        guard let modalId = sender.accessibilityIdentifier else { return }
        dismissModal(modalId: modalId, completion: nil)
    }
    
    private func dismissModal(modalId: String, completion: ((Bool) -> Void)?) {
        guard let controller = activeModals[modalId] else {
            completion?(false)
            return
        }
        
        // Notify Flutter to prepare for dismissal
        channel?.invokeMethod("setRoute", arguments: [
            "route": "/",  // or your default route
            "arguments": [:]
        ]) { [weak self] _ in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                // Dismiss the modal
                controller.dismiss(animated: true) {
                    self.activeModals.removeValue(forKey: modalId)
                    
                    // Refresh main Flutter view
                    if let mainVC = self.mainFlutterViewController {
                        mainVC.view.setNeedsLayout()
                        mainVC.view.layoutIfNeeded()
                    }
                    
                    completion?(true)
                }
            }
        }
    }
    
    private func dismissAllModals() -> Int {
        let count = activeModals.count
        for (modalId, _) in activeModals {
            dismissModal(modalId: modalId, completion: nil)
        }
        return count
    }
}
