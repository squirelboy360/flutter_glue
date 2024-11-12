//
//  NavigationTheme.swift
//  Runner
//
//  Created by Tahiru Agbanwa on 11/12/24.
//

import UIKit

struct NavigationTheme {
    var backgroundColor: UIColor
    var tintColor: UIColor
    var titleColor: UIColor
    var titleFont: UIFont
    var barStyle: UIBarStyle
    
    init() {
        backgroundColor = .systemBackground
        tintColor = .systemBlue
        titleColor = .label
        titleFont = .boldSystemFont(ofSize: 17)
        barStyle = .default
    }
    
    // Apply method to configure UINavigationBar
    func apply(to navigationBar: UINavigationBar) {
        navigationBar.barTintColor = backgroundColor
        navigationBar.tintColor = tintColor
        navigationBar.barStyle = barStyle
        navigationBar.titleTextAttributes = [
            .foregroundColor: titleColor,
            .font: titleFont
        ]
    }
    
    // Apply method to configure UITabBar
    func apply(to tabBar: UITabBar) {
        tabBar.barTintColor = backgroundColor
        tabBar.tintColor = tintColor
        tabBar.unselectedItemTintColor = titleColor.withAlphaComponent(0.6)
        tabBar.barStyle = barStyle
    }
}
