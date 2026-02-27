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
            title: "",
            onAdd: { print("Add new todo list") },
            onEdit: { print("Edit list name") }
        ) {
            DraggableSplitView(
                initialTopRatio: 0.3,  // Start with 30% top, 70% bottom
                minTopRatio: 0.1,      // Minimum 10% for top
                maxTopRatio: 0.85       // Maximum 90% for top
            ) {
                VStack(spacing: 0) {
                    // Custom list that includes both items and add input
                    List {
                        // Todo items
                        ForEach(items) { item in
                            TodoItemRow(
                                item: item,
                                onToggle: { toggleComplete(item) }
                            )
                        }
                        .onDelete(perform: deleteItems)
                        .onMove(perform: moveItem)

                        // Add input as the last item in the list
                        AddItemInputComponent(
                            text: $newTaskTitle,
                            placeholder: "New item",
                            buttonText: "Add",
                            onAdd: addItem
                        )
                        .focused($isInputFocused)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                    }
                    .listStyle(PlainListStyle())
                    .scrollContentBackground(.hidden)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            } bottomContent: {
                // Bottom content can be empty or used for other controls
                VStack {
                    Text("Additional controls can go here")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
        }
        .navigationTitle(listName)
        .navigationBarTitleDisplayMode(.inline)
        
        .onTapGesture {
            // Dismiss keyboard when tapping outside
            isInputFocused = false
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
                // Keep the input visible for adding more items
                // Focus stays active for quick successive additions
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isInputFocused = true
                }
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
