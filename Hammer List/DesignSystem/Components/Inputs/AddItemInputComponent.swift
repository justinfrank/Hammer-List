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
    
    init(
        text: Binding<String>,
        placeholder: String = "Add item",
        buttonText: String = "Add",
        onAdd: @escaping () -> Void
    ) {
        self._text = text
        self.placeholder = placeholder
        self.buttonText = buttonText
        self.onAdd = onAdd
    }
    
    var body: some View {
        HStack(spacing: AppTokens.Spacing._100) {
            TextField(placeholder, text: $text)
                .font(AppTokens.Typography.body)
                .padding(AppTokens.Spacing._100)
                .background(AppTokens.Colors.surface)
                .cornerRadius(AppTokens.CornerRadius.small)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTokens.CornerRadius.small)
                        .stroke(AppTokens.Colors.secondary.opacity(0.3), lineWidth: 1)
                )
                .onSubmit {
                    if !text.trimmingCharacters(in: .whitespaces).isEmpty {
                        onAdd()
                    }
                }
            
            AppButton(
                style: .primary,
                size: .medium,
                action: {
                    if !text.trimmingCharacters(in: .whitespaces).isEmpty {
                        onAdd()
                    }
                }
            ) {
                Text(buttonText)
            }
            .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(.horizontal, AppTokens.Spacing._200)
    }
}

#Preview {
    @State var sampleText = ""
    
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