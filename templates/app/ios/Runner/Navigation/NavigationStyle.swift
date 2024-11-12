//
//  NavigationStyle.swift
//  Runner
//
//  Created by Tahiru Agbanwa on 11/12/24.
//

import UIKit

struct NavigationStyle {
    let backgroundColor: UIColor
    let tintColor: UIColor
    let titleColor: UIColor
    let isDark: Bool
    
    init(from arguments: [String: Any]) {
        if let colorValue = arguments["backgroundColor"] as? Int {
            self.backgroundColor = UIColor(
                red: CGFloat((colorValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((colorValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(colorValue & 0x0000FF) / 255.0,
                alpha: 1.0
            )
        } else {
            self.backgroundColor = .systemBackground
        }
        
        if let colorValue = arguments["tintColor"] as? Int {
            self.tintColor = UIColor(
                red: CGFloat((colorValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((colorValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(colorValue & 0x0000FF) / 255.0,
                alpha: 1.0
            )
        } else {
            self.tintColor = .systemBlue
        }
        
        if let colorValue = arguments["titleColor"] as? Int {
            self.titleColor = UIColor(
                red: CGFloat((colorValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((colorValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(colorValue & 0x0000FF) / 255.0,
                alpha: 1.0
            )
        } else {
            self.titleColor = .label
        }
        
        self.isDark = arguments["isDark"] as? Bool ?? false
    }
    
    func apply(to navigationBar: UINavigationBar) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = backgroundColor
        appearance.titleTextAttributes = [
            .foregroundColor: titleColor
        ]
        
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        if #available(iOS 15.0, *) {
            navigationBar.compactScrollEdgeAppearance = appearance
        }
        
        navigationBar.tintColor = tintColor
        navigationBar.barStyle = isDark ? .black : .default
    }
}
