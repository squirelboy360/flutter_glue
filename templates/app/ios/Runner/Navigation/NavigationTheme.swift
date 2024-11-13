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
    
    var tabBarTintColor: UIColor {
        return tintColor
    }
    
    var tabBarUnselectedItemTintColor: UIColor {
        return titleColor.withAlphaComponent(0.6)
    }
    
    func apply(to navigationBar: UINavigationBar) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = backgroundColor
        appearance.titleTextAttributes = [
            .foregroundColor: titleColor,
            .font: titleFont
        ]
        
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        if #available(iOS 15.0, *) {
            navigationBar.compactScrollEdgeAppearance = appearance
        }
        
        navigationBar.tintColor = tintColor
        navigationBar.barStyle = barStyle
    }
    
    func apply(to tabBar: UITabBar) {
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            appearance.backgroundColor = backgroundColor
            
            appearance.stackedLayoutAppearance.normal.iconColor = tabBarUnselectedItemTintColor
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: tabBarUnselectedItemTintColor
            ]
            
            appearance.stackedLayoutAppearance.selected.iconColor = tabBarTintColor
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: tabBarTintColor
            ]
            
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        } else {
            tabBar.barTintColor = backgroundColor
            tabBar.tintColor = tabBarTintColor
            tabBar.unselectedItemTintColor = tabBarUnselectedItemTintColor
        }
    }
}
