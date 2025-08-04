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
    
    var body: some View {
        List(AppPage.allCases, selection: $selectedPage) { page in
            switch page {
            case .list:
                Text(listName)
                    .font(AppTokens.Typography.body)
                    .foregroundColor(AppTokens.Colors.text)
                    .tag(page)
            case .settings, .about:
                Text(page.rawValue)
                    .font(AppTokens.Typography.body)
                    .foregroundColor(AppTokens.Colors.text)
                    .tag(page)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Text("Menu")
                    .font(AppTokens.Typography.headline)
                    .foregroundColor(AppTokens.Colors.text)
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

