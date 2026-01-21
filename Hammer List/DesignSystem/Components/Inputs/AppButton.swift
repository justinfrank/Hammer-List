//
//  AppButton.swift
//  Hammer List
//
//  Created by Justin Frank on 8/3/25.
//

import SwiftUI

struct AppButton<Content: View>: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.colorScheme) private var systemScheme: ColorScheme

    private var theme: AppTheme {
        let effective = themeManager.followSystem ? systemScheme : themeManager.override.colorScheme
        return themeManager.theme(for: effective)
    }

    enum Style {
        case brand, secondary, tertiary
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
        style: Style = .brand,
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
                .foregroundColor(foregroundColor(for: style))
                .padding(size.padding)
                .background(backgroundColor(for: style))
                .cornerRadius(AppTokens.CornerRadius.small)
        }
    }

    private func backgroundColor(for style: Style) -> Color {
        switch style {
        case .brand: return theme.brand
        case .secondary: return theme.surface
        case .tertiary: return Color.clear
        }
    }

    private func foregroundColor(for style: Style) -> Color {
        switch style {
        case .brand: return .white
        case .secondary: return theme.text
        case .tertiary: return theme.brand
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        AppButton(style: .brand, action: {}) {
            Text("Brand Button")
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