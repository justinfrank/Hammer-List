//
//  AppSidebarView.swift
//  Hammer List
//
//  Created by Justin Frank on 8/3/25.
//

import SwiftUI

struct AppSidebarView: View {
    @Binding var selectedPage: AppPage?
    @State private var listName: String = "My Tasks"

    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.colorScheme) private var systemScheme: ColorScheme

    private var theme: AppTheme {
        let effective = themeManager.followSystem ? systemScheme : themeManager.override.colorScheme
        return themeManager.theme(for: effective)
    }
    
    var body: some View {
      List(AppPage.allCases, selection: $selectedPage) { page in
        switch page {
        case .list:
            Text(listName)  // Keep your custom list name
                .font(AppTokens.Typography.body)
                .foregroundColor(theme.text)
                .tag(page)
        case .home, .settings, .about:
            Text(page.title)  // Use the title from the enum
                .font(AppTokens.Typography.body)
                .foregroundColor(theme.text)
                .tag(page)
        }
    }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Text("Menu")
                    .font(AppTokens.Typography.headline)
                    .foregroundColor(theme.text)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                AppButton(
                    style: .tertiary,
                    size: .small,
                    action: { 
                        print("Add new list - will implement later")
                    }
                ) {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

