//
//  TestDataManager.swift
//  Hammer List
//
//  Created by Justin Frank on 7/15/25.
//

import Foundation
import SwiftData

struct TestDataManager {
    static func addTestData(to modelContext: ModelContext) {
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