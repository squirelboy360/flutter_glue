//
//   ModalConfiguration.swift
//  Runner
//
//  Created by Tahiru Agbanwa on 11/12/24.
//

import UIKit

struct ModalConfiguration {
    let presentationStyle: String
    let detents: [String]
    let isDismissible: Bool
    let showDragIndicator: Bool
    let showHeader: Bool
    let headerTitle: String?
    let showCloseButton: Bool
    let style: ModalStyle
    
    init(from arguments: [String: Any]) {
        self.presentationStyle = arguments["presentationStyle"] as? String ?? "sheet"
        self.detents = arguments["detents"] as? [String] ?? ["large"]
        self.isDismissible = arguments["isDismissible"] as? Bool ?? true
        self.showDragIndicator = arguments["showDragIndicator"] as? Bool ?? true
        self.showHeader = (arguments["showNativeHeader"] as? String ?? "true").lowercased() == "true"
        self.headerTitle = arguments["headerTitle"] as? String
        self.showCloseButton = (arguments["showCloseButton"] as? String ?? "false").lowercased() == "true"
        self.style = ModalStyle(from: arguments)
    }
}
