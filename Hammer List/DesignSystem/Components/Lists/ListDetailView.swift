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
    @State private var selectedChildItem: Item? = nil
    @State private var selectedChildList: ItemList? = nil
    @State private var itemForChildList: Item? = nil
    @State private var isImportingList = false
    @State private var isEditingListName = false
    @State private var editedListName = ""
    @FocusState private var isInputFocused: Bool
    
    // Query items that belong to this specific list
    private var items: [Item] {
        list.items.sorted { $0.order < $1.order }
    }
    
    var body: some View {
        // TODO: Re-wrap with DraggableSplitView when bottom panel has real content
        VStack(spacing: 0) {
            List {
                ForEach(items, id: \.id) { item in
                    TodoItemRow(
                        item: item,
                        onToggle: { toggleComplete(item) },
                        childListCount: item.hasChildLists ? item.childItemCount : nil,
                        onNavigate: {
                            let childLists = item.childLists.sorted { $0.order < $1.order }
                            if childLists.count == 1 {
                                selectedChildList = childLists.first
                            } else {
                                selectedChildItem = item
                            }
                        },
                        onAddChildList: { itemForChildList = item }
                    )
                }
                .onDelete(perform: deleteItems)
                .onMove(perform: moveItem)
            }
            .listStyle(PlainListStyle())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 6) {
                    Text(list.name)
                        .font(AppTokens.Typography.headline)
                    Button {
                        editedListName = list.name
                        isEditingListName = true
                    } label: {
                        Image(systemName: "pencil")
                            .font(.footnote)
                    }
                }
            }
        }
        .alert("Rename List", isPresented: $isEditingListName) {
            TextField("List name", text: $editedListName)
            Button("Save") {
                list.name = editedListName
                try? modelContext.save()
            }
            Button("Cancel", role: .cancel) { }
        }
        .navigationDestination(item: $selectedChildItem) { item in
            ItemChildListsView(item: item)
        }
        .navigationDestination(item: $selectedChildList) { list in
            ListDetailView(list: list)
        }
        .sheet(item: $itemForChildList) { item in
            AddListModal(parentItem: item)
        }
        .sheet(isPresented: $isImportingList) {
            ImportListSheet(targetList: list)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            AddItemInputComponent(
                text: $newTaskTitle,
                placeholder: "New task",
                buttonText: "Add",
                onAdd: addItem,
                onAddAsNested: addItemAsNested,
                onImportList: { isImportingList = true }
            )
            .focused($isInputFocused)
            .shadow(
                color: AppTokens.Elevation.medium.color,
                radius: AppTokens.Elevation.medium.radius,
                x: AppTokens.Elevation.medium.x,
                y: AppTokens.Elevation.medium.y
            )
            .padding(.horizontal, AppTokens.Spacing._200)
            .padding(.bottom, AppTokens.Spacing._200)
        }
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
    
    private func addItemAsNested() {
        withAnimation {
            let maxOrder = items.map(\.order).max() ?? 0
            let newItem = Item(
                title: newTaskTitle,
                timestamp: Date(),
                order: maxOrder + 1
            )
            list.items.append(newItem)
            try? modelContext.save()
            newTaskTitle = ""
            itemForChildList = newItem
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
