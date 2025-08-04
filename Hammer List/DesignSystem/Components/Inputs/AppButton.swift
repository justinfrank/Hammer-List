//
//  AppButton.swift
//  Hammer List
//
//  Created by Justin Frank on 8/3/25.
//

import SwiftUI

struct AppButton<Content: View>: View {
    enum Style {
        case primary, secondary, tertiary
        
        var backgroundColor: Color {
            switch self {
            case .primary: return AppTokens.Colors.primary
            case .secondary: return AppTokens.Colors.surface
            case .tertiary: return Color.clear
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .primary: return .white
            case .secondary: return AppTokens.Colors.text
            case .tertiary: return AppTokens.Colors.primary
            }
        }
    }
    
    enum Size {
        case small, medium, large
        
        var padding: EdgeInsets {
            switch self {
            case .small: return EdgeInsets(
                top: AppTokens.Spacing._50, 
                leading: AppTokens.Spacing._100, 
                bottom: AppTokens.Spacing._50, 
                trailing: AppTokens.Spacing._100
            )
            case .medium: return EdgeInsets(
                top: AppTokens.Spacing._100, 
                leading: AppTokens.Spacing._200, 
                bottom: AppTokens.Spacing._100, 
                trailing: AppTokens.Spacing._200
            )
            case .large: return EdgeInsets(
                top: AppTokens.Spacing._200, 
                leading: AppTokens.Spacing._300, 
                bottom: AppTokens.Spacing._200, 
                trailing: AppTokens.Spacing._300
            )
            }
        }
    }
    
    let style: Style
    let size: Size
    let action: () -> Void
    let content: Content
    
    init(
        style: Style = .primary,
        size: Size = .medium,
        action: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.style = style
        self.size = size
        self.action = action
        self.content = content()
    }
    
    var body: some View {
        Button(action: action) {
            content
                .font(AppTokens.Typography.button)
                .foregroundColor(style.foregroundColor)
                .padding(size.padding)
                .background(style.backgroundColor)
                .cornerRadius(AppTokens.CornerRadius.small)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        AppButton(style: .primary, action: {}) {
            Text("Primary Button")
        }
        
        AppButton(style: .secondary, action: {}) {
            Text("Secondary Button")
        }
        
        AppButton(style: .tertiary, size: .small, action: {}) {
            Image(systemName: "plus")
        }
    }
    .padding()
}