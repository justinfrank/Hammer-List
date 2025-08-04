//
//  BaseListView.swift
//  Hammer List
//
//  Created by Justin Frank on 8/3/25.
//

import SwiftUI

struct BaseListView<Content: View>: View {
    let title: String
    let content: Content
    let onAdd: (() -> Void)?
    let onEdit: (() -> Void)?
    
    init(
        title: String,
        onAdd: (() -> Void)? = nil,
        onEdit: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.onAdd = onAdd
        self.onEdit = onEdit
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // List Header
            ListHeaderComponent(
                title: title,
                onAdd: onAdd,
                onEdit: onEdit
            )
            
            // List Content
            content
                .background(AppTokens.Colors.background)
        }
    }
}

// MARK: - List Header Component
struct ListHeaderComponent: View {
    let title: String
    let onAdd: (() -> Void)?
    let onEdit: (() -> Void)?
    
    var body: some View {
        HStack {
            Text(title)
                .font(AppTokens.Typography.headline)
                .foregroundColor(AppTokens.Colors.text)
            
            Spacer()
            
            HStack(spacing: AppTokens.Spacing._100) {
                if let onEdit = onEdit {
                    AppButton(
                        style: .tertiary,
                        size: .small,
                        action: onEdit
                    ) {
                        Image(systemName: "pencil")
                    }
                }
                
                if let onAdd = onAdd {
                    AppButton(
                        style: .tertiary,
                        size: .small,
                        action: onAdd
                    ) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .padding(.horizontal, AppTokens.Spacing._200)
        .padding(.vertical, AppTokens.Spacing._100)
        .background(AppTokens.Colors.surface)
    }
}

#Preview {
    BaseListView(
        title: "Sample List",
        onAdd: { print("Add tapped") },
        onEdit: { print("Edit tapped") }
    ) {
        VStack {
            Text("List content goes here")
                .padding()
            Text("This could be any list type")
                .padding()
            Text("Todo, shopping, notes, etc.")
                .padding()
        }
    }
}