//
//  AddListModal.swift
//  Hammer List
//
//  Created by Justin Frank on [Current Date]
//

import SwiftUI
import SwiftData

struct AddListModal: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: [SortDescriptor(\ItemList.order, order: .forward)]) private var existingLists: [ItemList]
    
    @State private var listName: String = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("List Name")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextField("Enter list name", text: $listName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .focused($isTextFieldFocused)
                        .onSubmit {
                            createList()
                        }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("New List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        createList()
                    }
                    .disabled(listName.trimmingCharacters(in: .whitespaces).isEmpty)
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.height(300), .medium])
        .presentationDragIndicator(.visible)
        .onAppear {
            // Focus the text field when the modal appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isTextFieldFocused = true
            }
        }
    }
    
    private func createList() {
        let trimmedName = listName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }
        
        // Set order to be after the last list
        let maxOrder = existingLists.map(\.order).max() ?? -1
        
        let newList = ItemList(name: trimmedName)
        newList.order = maxOrder + 1
        modelContext.insert(newList)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error saving new list: \(error)")
        }
    }
}

#Preview {
    AddListModal()
        .modelContainer(for: [ItemList.self, Item.self], inMemory: true)
}