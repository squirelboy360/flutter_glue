//
//  ModalStyle.swift
//  Runner
//
//  Created by Tahiru Agbanwa on 11/12/24.
//

import UIKit

struct ModalStyle {
    let backgroundColor: UIColor?
    
    init(from arguments: [String: Any]) {
        if let colorValue = arguments["backgroundColor"] as? Int {
            self.backgroundColor = UIColor(
                red: CGFloat((colorValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((colorValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(colorValue & 0x0000FF) / 255.0,
                alpha: 1.0
            )
        } else {
            self.backgroundColor = nil
        }
    }
}
