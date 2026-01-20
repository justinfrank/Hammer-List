//
//  ItemList.swift
//  Hammer List
//
//  Created by Justin Frank on [Current Date]
//

import SwiftData
import Foundation

@Model
final class ItemList {
    var id = UUID()
    var name: String
    var createdAt: Date
    var order: Int = 0
    @Relationship(deleteRule: .cascade) var items: [Item] = []
    
    init(name: String) {
        self.name = name
        self.createdAt = Date()
        self.order = 0
    }
}