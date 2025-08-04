import Foundation
import SwiftUI

class ListViewModel<T: ListItemProtocol>: ObservableObject {
    @Published var items: [T] = []
    @Published var newItemTitle: String = ""
    
    // Add a new item (requires a factory closure for T)
    func addItem(factory: (String, Int) -> T) {
        let trimmedTitle = newItemTitle.trimmingCharacters(in: .whitespaces)
        guard !trimmedTitle.isEmpty else { return }
        let maxOrder = items.map { $0.order }.max() ?? -1
        let newOrder = maxOrder + 1
        let newItem = factory(trimmedTitle, newOrder)
        items.append(newItem)
        newItemTitle = ""
    }
    
    // Toggle status (requires cycling logic for status)
    func toggleComplete(_ item: T, statusCycle: (T.Status) -> T.Status) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        var updated = items[index]
        updated.status = statusCycle(updated.status)
        items[index] = updated
    }
    
    // Delete items
    func deleteItems(offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }
    
    // Move items
    func moveItem(from source: IndexSet, to destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
        for (index, var item) in items.enumerated() {
            if item.order != index {
                item.order = index
                items[index] = item
            }
        }
    }
    
    // Add test data (requires a factory closure for T)
    func addTestData(testItems: [T]) {
        items.append(contentsOf: testItems)
    }
} 