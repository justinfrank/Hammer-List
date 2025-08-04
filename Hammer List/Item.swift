//
//  Item.swift
//  Hammer List
//
//  Created by Justin Frank on 7/15/25.
//

import Foundation
import SwiftData

protocol ListItemStatus: CaseIterable, Equatable {}

protocol ListItemProtocol: Identifiable {
    associatedtype Status: ListItemStatus
    var id: UUID { get }
    var title: String { get set }
    var status: Status { get set }
    var order: Int { get set }
    var timestamp: Date { get set }
}

// Make TodoStatus conform to ListItemStatus
enum TodoStatus: Int, Codable, CaseIterable, ListItemStatus {
    case notStarted
    case inProgress
    case completed
}

@Model
final class Item: ListItemProtocol {
    @Attribute(.unique) var id: UUID
    var title: String
    var status: TodoStatus
    var timestamp: Date
    var order: Int
    
    init(id: UUID = UUID(), title: String, status: TodoStatus = .notStarted, timestamp: Date, order: Int = 0) {
        self.id = id
        self.title = title
        self.status = status
        self.timestamp = timestamp
        self.order = order
    }
}
