//
//  AppDetailView.swift
//  Hammer List
//
//  Created by Justin Frank on 8/3/25.
//

import SwiftUI

struct AppDetailView: View {
    let selectedPage: AppPage?
    
    var body: some View {
        switch selectedPage {
        case .list:
            TodoListView()
        case .settings:
            SettingsView()
        case .about:
            AboutView()
        case .none:
            VStack {
                Image(systemName: "sidebar.left")
                    .font(.system(size: 48))
                    .foregroundColor(AppTokens.Colors.textSecondary)
                
                Text("Select a page")
                    .font(AppTokens.Typography.body)
                    .foregroundColor(AppTokens.Colors.textSecondary)
                    .padding(.top, AppTokens.Spacing.small)
            }
        }
    }
}