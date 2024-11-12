import Flutter
import UIKit

class ModalController {
    static let shared = ModalController()
    private var channel: FlutterMethodChannel?
    private var activeModals: [String: UINavigationController] = [:]
    private var modalCounter: Int = 0
    private weak var flutterEngine: FlutterEngine?
    
    private init() {}
    
    func setup(with engine: FlutterEngine, controller: FlutterViewController) {
        self.flutterEngine = engine
        
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
        
        let flutterViewController = FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil)
        let navController = UINavigationController(rootViewController: flutterViewController)
        
        // Set route before presenting
        channel?.invokeMethod("setRoute", arguments: [
            "route": route,
            "arguments": arguments
        ])
        
        // Configure modal
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
        if let backgroundColor = config.style.backgroundColor {
            navController.view.backgroundColor = backgroundColor
        }
        
        navController.navigationBar.isHidden = !config.showHeader
        if config.showHeader {
            flutterViewController.title = config.headerTitle
            
            if config.showCloseButton {
                modalCounter += 1
                let closeButton = UIBarButtonItem(
                    title: "Close",
                    style: .done,
                    target: self,
                    action: #selector(closeModalTapped(_:))
                )
                closeButton.tag = modalCounter
                flutterViewController.navigationItem.rightBarButtonItem = closeButton
            }
        }
        
        let modalId = "modal_\(modalCounter)"
        activeModals[modalId] = navController
        
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
            rootViewController.present(navController, animated: true) {
                completion(modalId)
            }
        }
    }
    
    @objc private func closeModalTapped(_ sender: UIBarButtonItem) {
        let modalId = "modal_\(sender.tag)"
        dismissModal(modalId: modalId, completion: nil)
    }
    
    private func dismissModal(modalId: String, completion: ((Bool) -> Void)?) {
        if let controller = activeModals[modalId] {
            controller.dismiss(animated: true) { [weak self] in
                self?.activeModals.removeValue(forKey: modalId)
                completion?(true)
            }
        } else {
            completion?(false)
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
