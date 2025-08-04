//
//  TodoListView.swift
//  Hammer List
//
//  Created by Justin Frank on 8/3/25.
//

import SwiftUI
import SwiftData

struct TodoListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Item.order, order: .forward)]) private var items: [Item]
    
    @State private var newTaskTitle: String = ""
    @State private var listName: String = "My Tasks"
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        BaseListView(
            title: listName,
            onAdd: { print("Add new todo list") },
            onEdit: { print("Edit list name") }
        ) {
            VStack {
                TodoListContainer(
                    items: items,
                    onDelete: deleteItems,
                    onMove: moveItem,
                    onToggleComplete: toggleComplete
                )
                Spacer()
                AddItemInputComponent(
                    text: $newTaskTitle,
                    placeholder: "New task",
                    buttonText: "Add",
                    onAdd: addItem
                )
                .focused($isInputFocused)
            }
        }
        .onAppear {
            if items.isEmpty {
                TestDataManager.addTestData(to: modelContext)
            }
            DebugHelper.checkForDuplicateIDs(in: items)
        }
    }
    
    // MARK: - Private Methods
    private func addItem() {
        withAnimation {
            ItemManager.addItem(
                title: newTaskTitle,
                items: items,
                modelContext: modelContext
            ) {
                newTaskTitle = ""
                isInputFocused = false
            }
        }
    }
    
    private func toggleComplete(_ item: Item) {
        ItemManager.toggleComplete(item, in: items)
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            ItemManager.deleteItems(offsets: offsets, items: items, modelContext: modelContext)
        }
    }
    
    private func moveItem(from source: IndexSet, to destination: Int) {
        ItemManager.moveItem(from: source, to: destination, items: items, modelContext: modelContext)
    }
}