//
//  ContentView.swift
//  Hammer List
//
//  Created by Justin Frank on 7/15/25.
//

import SwiftUI
import SwiftData

enum AppPage: String, CaseIterable, Identifiable, Hashable {
    case list // Main list page
    case settings = "Settings"
    case about = "About"

    var id: String { self.rawValue }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Item.order, order: .forward)]) private var items: [Item]
    
    @State private var newTaskTitle: String = ""
    @FocusState private var isInputFocused: Bool
    @State private var listName: String = "My Tasks"
    @State private var isMenuOpen: Bool = false
    @State private var selectedPage: AppPage? = .list

    var body: some View {
        NavigationSplitView {
            List(AppPage.allCases, selection: $selectedPage) { page in
                switch page {
                case .list:
                    Text(listName)
                        .tag(page)
                case .settings, .about:
                    Text(page.rawValue)
                        .tag(page)
                }
            }
            // .navigationTitle("Menu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Menu")
                        .font(.headline)
                        .fontWeight(.bold)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Add button action
                        // addNewItem()
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        } detail: {
            switch selectedPage {
            case .list:
                VStack {
                    ListHeader<EmptyView>(listName: $listName)
                    TodoListContainer(
                        items: items,
                        onDelete: deleteItems,
                        onMove: moveItem,
                        onToggleComplete: toggleComplete
                    )
                    Spacer()
                    AddListItemInput(
                        text: $newTaskTitle,
                        placeholder: "New task",
                        buttonLabel: "Add",
                        onAdd: addItem
                    )
                    .focused($isInputFocused)
                    .padding(.bottom)
                }
            case .settings:
                SettingsView()
            case .about:
                AboutView()
            case .none:
                Text("Select a page")
            }
        }
        .onAppear {
            if items.isEmpty {
                addTestData()
            }
            // Debug: Print duplicate IDs
            let ids = items.map { $0.id }
            let duplicates = Dictionary(grouping: ids, by: { $0 }).filter { $1.count > 1 }
            if !duplicates.isEmpty {
                print("Duplicate IDs: \(duplicates)")
            }
        }
        .offset(x: isMenuOpen ? 250 : 0) // Push content to the right
        .disabled(isMenuOpen) // Prevent interaction when menu is open

        // Side Drawer
        if isMenuOpen {
            SideMenu(isMenuOpen: $isMenuOpen) {
                isMenuOpen = false
            }
        }
    }

    private func addItem() {
        let trimmedTitle = newTaskTitle.trimmingCharacters(in: .whitespaces)
        guard !trimmedTitle.isEmpty else { return }
        let maxOrder = items.map { $0.order }.max() ?? -1
        let newOrder = maxOrder + 1
        withAnimation {
            let newItem = Item(title: trimmedTitle, status: .notStarted, timestamp: Date(), order: newOrder)
            modelContext.insert(newItem)
        }
        newTaskTitle = ""
        isInputFocused = false
    }

    private func toggleComplete(_ item: Item) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            let current = items[index].status
            let allCases = TodoStatus.allCases
            if let nextIndex = allCases.firstIndex(of: current).map({ ($0 + 1) % allCases.count }) {
                items[index].status = allCases[nextIndex]
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }

    private func moveItem(from source: IndexSet, to destination: Int) {
        var revisedItems = items
        revisedItems.move(fromOffsets: source, toOffset: destination)
        for (index, item) in revisedItems.enumerated() {
            if item.order != index {
                item.order = index
                modelContext.insert(item) // This will update the item in SwiftData
            }
        }
    }

    private func addTestData() {
        let testItems = [
            Item(id: UUID(), title: "Buy groceries", status: .notStarted, timestamp: Date(), order: 0),
            Item(id: UUID(), title: "Walk the dog", status: .inProgress, timestamp: Date().addingTimeInterval(-3600), order: 1),
            Item(id: UUID(), title: "Read a book", status: .completed, timestamp: Date().addingTimeInterval(-7200), order: 2)
        ]
        for item in testItems {
            modelContext.insert(item)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
