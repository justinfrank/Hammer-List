//
//  ListDetailView.swift
//  Hammer List
//
//  Created by Justin Frank on [Current Date]
//

import SwiftUI
import SwiftData

struct ListDetailView: View {
    @Environment(\.modelContext) private var modelContext
    let list: ItemList
    
    @State private var newTaskTitle: String = ""
    @FocusState private var isInputFocused: Bool
    
    // Query items that belong to this specific list
    private var items: [Item] {
        list.items.sorted { $0.order < $1.order }
    }
    
    var body: some View {
        BaseListView(
            title: "",
            onAdd: { print("Add new todo list") },
            onEdit: { print("Edit list name") }
        ) {
            DraggableSplitView(
                initialTopRatio: 0.6,  // Start with 30% top, 70% bottom
                minTopRatio: 0.1,      // Minimum 10% for top
                maxTopRatio: 0.85       // Maximum 90% for top
            ) {
                VStack(spacing: 0) {
                    // Custom list that includes both items and add input
                    List {
                        // Todo items from this specific list
                        ForEach(items, id: \.id) { item in
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
                            placeholder: "New task",
                            buttonText: "Add",
                            onAdd: addItem
                        )
                        .focused($isInputFocused)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
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
        .navigationTitle(list.name)
        .navigationBarTitleDisplayMode(.inline)
        .onTapGesture {
            // Dismiss keyboard when tapping outside
            isInputFocused = false
        }
        .onAppear {
          DebugHelper.checkForDuplicateIDs(in: items)
          
          // Fix any existing items with invalid status
          for item in items {
              // This will ensure all items have valid TodoStatus values
              if item.status != .notStarted && item.status != .inProgress && item.status != .completed {
                  item.status = .completed // Assume old "checked" items were completed
              }
          }
          try? modelContext.save()
      }
    }
    
    // MARK: - Private Methods
    private func addItem() {
        withAnimation {
            // Create new item and add it to this specific list
            let maxOrder = items.map(\.order).max() ?? 0
            let newItem = Item(
                title: newTaskTitle, 
                timestamp: Date(),
                order: maxOrder + 1
            )
            
            // Add to the list's items
            list.items.append(newItem)
            
            // Save to context
            try? modelContext.save()
            
            // Clear input and maintain focus
            newTaskTitle = ""
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isInputFocused = true
            }
        }
    }
    
    private func toggleComplete(_ item: Item) {
        // Use the same logic as your TodoListView
        ItemManager.toggleComplete(item, in: items)
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            let itemsToDelete = offsets.map { items[$0] }
            for item in itemsToDelete {
                if let index = list.items.firstIndex(of: item) {
                    list.items.remove(at: index)
                }
            }
            try? modelContext.save()
        }
    }
    
    private func moveItem(from source: IndexSet, to destination: Int) {
        // Reorder items within this list
        var mutableItems = items
        mutableItems.move(fromOffsets: source, toOffset: destination)
        
        // Update order values
        for (index, item) in mutableItems.enumerated() {
            item.order = index
        }
        
        try? modelContext.save()
    }
}
