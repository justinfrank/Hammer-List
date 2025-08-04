struct DebugHelper {
    static func checkForDuplicateIDs(in items: [Item]) {
        let ids = items.map { $0.id }
        let duplicates = Dictionary(grouping: ids, by: { $0 }).filter { $1.count > 1 }
        if !duplicates.isEmpty {
            print("Duplicate IDs: \(duplicates)")
        }
    }
}