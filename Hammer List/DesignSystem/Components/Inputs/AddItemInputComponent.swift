//
//  AddItemInputComponent.swift
//  Hammer List
//
//  Created by Justin Frank on 8/3/25.
//

import SwiftUI

struct AddItemInputComponent: View {
    @Binding var text: String
    let placeholder: String
    let buttonText: String
    let onAdd: () -> Void
    let onAddAsNested: (() -> Void)?
    let onImportList: (() -> Void)?

    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.colorScheme) private var systemScheme: ColorScheme

    private var theme: AppTheme {
        let effective = themeManager.followSystem ? systemScheme : themeManager.override.colorScheme
        return themeManager.theme(for: effective)
    }
    
    init(
        text: Binding<String>,
        placeholder: String = "Add item",
        buttonText: String = "Add",
        onAdd: @escaping () -> Void,
        onAddAsNested: (() -> Void)? = nil,
        onImportList: (() -> Void)? = nil
    ) {
        self._text = text
        self.placeholder = placeholder
        self.buttonText = buttonText
        self.onAdd = onAdd
        self.onAddAsNested = onAddAsNested
        self.onImportList = onImportList
    }
    
    var body: some View {
        HStack(spacing: AppTokens.Spacing._100)
        {
            TextField(placeholder, text: $text)
                .font(AppTokens.Typography.body)
                .foregroundColor(.primary)
                .padding(AppTokens.Spacing._100)
                .background(Color.clear)
                .cornerRadius(AppTokens.CornerRadius.small)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTokens.CornerRadius.small)
                        .stroke(theme.neutral.opacity(0.3), lineWidth: 1)
                )
                .onSubmit {
                    if !text.trimmingCharacters(in: .whitespaces).isEmpty {
                        onAdd()
                    }
                }

            Image(systemName: "plus")
                .font(AppTokens.Typography.body)
                .foregroundColor(.white)
                .padding(AppTokens.Spacing._100)
                .background(theme.brand)
                .clipShape(Circle())
                .onTapGesture {
                    if !text.trimmingCharacters(in: .whitespaces).isEmpty {
                        onAdd()
                    }
                }
                .contextMenu {
                    if !text.trimmingCharacters(in: .whitespaces).isEmpty {
                        Button {
                            onAddAsNested?()
                        } label: {
                            Label("Add as Nested List", systemImage: "list.bullet.indent")
                        }
                    }
                    Button {
                        onImportList?()
                    } label: {
                        Label("Import List", systemImage: "tray.and.arrow.down")
                    }
                }
        }
        .padding(.horizontal, AppTokens.Spacing._200)
        .padding(.vertical, AppTokens.Spacing._100)
        .background(theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTokens.CornerRadius.large))
    }
}

#Preview {
    @Previewable @State var sampleText = ""
    
    return VStack(spacing: 20) {
        AddItemInputComponent(
            text: $sampleText,
            placeholder: "New task",
            buttonText: "Add"
        ) {
            print("Added: \(sampleText)")
            sampleText = ""
        }
        
        AddItemInputComponent(
            text: $sampleText,
            placeholder: "New note",
            buttonText: "Save"
        ) {
            print("Saved: \(sampleText)")
            sampleText = ""
        }
    }
    .padding()
}

