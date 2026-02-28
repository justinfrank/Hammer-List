//
//  ItemManager.swift
//  Hammer List
//
//  Created by Justin Frank on 7/15/25.
//

import Foundation
import SwiftData
import SwiftUI

struct ItemManager {
    static func addItem(title: String, items: [Item], modelContext: ModelContext, completion: @escaping () -> Void) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        guard !trimmedTitle.isEmpty else { return }
        
        let maxOrder = items.lazy.map { $0.order }.max() ?? -1
        let newOrder = maxOrder + 1
        
        let newItem = Item(title: trimmedTitle, status: .notStarted, timestamp: Date(), order: newOrder)
        modelContext.insert(newItem)
        completion()
    }
    
    static func toggleComplete(_ item: Item, in items: [Item]) {
        let current = item.status
        let allCases = TodoStatus.allCases
        if let currentIndex = allCases.firstIndex(of: current) {
            let nextIndex = (currentIndex + 1) % allCases.count
            item.status = allCases[nextIndex]
            
            // Force SwiftData to recognize the change
            item.timestamp = Date() // This triggers a change detection
        }
    }
    
    static func deleteItems(offsets: IndexSet, items: [Item], modelContext: ModelContext) {
        for index in offsets {
            let item = items[index]
            // Child lists with only this item as their parent are exclusively owned — delete them.
            // Shared lists (parentItems.count > 1) survive; this item is just removed from their parentItems.
            for list in item.childLists where list.parentItems.count <= 1 {
                modelContext.delete(list)
            }
            modelContext.delete(item)
        }
    }
    
    static func addChildList(to item: Item, name: String, modelContext: ModelContext) {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }

        let newList = ItemList(name: trimmedName)
        newList.order = item.childLists.count
        modelContext.insert(newList)
        item.childLists.append(newList)
    }

    static func moveItem(from source: IndexSet, to destination: Int, items: [Item], modelContext: ModelContext) {
        var revisedItems = items
        revisedItems.move(fromOffsets: source, toOffset: destination)
        for (index, item) in revisedItems.enumerated() {
            if item.order != index {
                item.order = index
            }
        }
    }
}