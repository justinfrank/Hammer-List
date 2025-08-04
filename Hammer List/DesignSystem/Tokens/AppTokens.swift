//
//  AppTokens.swift
//  Hammer List
//
//  Created by Justin Frank on 8/3/25.
//

import SwiftUI

struct AppTokens {
    
    // MARK: - Colors
    struct Colors {
        static let primary = Color.blue
        static let secondary = Color.gray
        static let background = Color(UIColor.systemBackground)
        static let surface = Color(UIColor.secondarySystemBackground)
        static let text = Color(UIColor.label)
        static let textSecondary = Color(UIColor.secondaryLabel)
        static let accent = Color.orange
        static let destructive = Color.red
    }
    
    // MARK: - Typography
    struct Typography {
        static let title = Font.largeTitle.weight(.bold)
        static let headline = Font.headline.weight(.semibold)
        static let body = Font.body
        static let caption = Font.caption
        static let button = Font.body.weight(.medium)
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let _50: CGFloat = 4
        static let _100: CGFloat = 8
        static let _200: CGFloat = 16
        static let _300: CGFloat = 24
        static let _400: CGFloat = 32
        static let _500: CGFloat = 48
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
    }
}