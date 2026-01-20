//
//  AppPage.swift
//  Hammer List
//
//  Created by Justin Frank on 7/15/25.
//

import Foundation


// 1. Update your AppPage enum to include a home/overview option
enum AppPage: String, CaseIterable, Identifiable {
    case home = "home"
    case list = "list"
    case settings = "settings"
    case about = "about"
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .home:
            return "All Lists"
        case .list:
            return "List"
        case .settings:
            return "Settings"
        case .about:
            return "About"
        }
    }
    
    var systemImage: String {
        switch self {
        case .home:
            return "house"
        case .list:
            return "list.bullet"
        case .settings:
            return "gear"
        case .about:
            return "info.circle"
        }
    }
}