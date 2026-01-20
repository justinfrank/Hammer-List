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
        
        let maxOrder = items.map { $0.order }.max() ?? -1
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
            modelContext.delete(items[index])
        }
    }
    
    static func moveItem(from source: IndexSet, to destination: Int, items: [Item], modelContext: ModelContext) {
        var revisedItems = items
        revisedItems.move(fromOffsets: source, toOffset: destination)
        for (index, item) in revisedItems.enumerated() {
            if item.order != index {
                item.order = index
                modelContext.insert(item)
            }
        }
    }
}