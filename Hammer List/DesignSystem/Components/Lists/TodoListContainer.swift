import SwiftUI

struct TodoListContainer<T: ListItemProtocol>: View where T.Status == TodoStatus {
    let items: [T]
    let onDelete: (IndexSet) -> Void
    let onMove: (IndexSet, Int) -> Void
    let onToggleComplete: (T) -> Void
    var childListCountProvider: ((T) -> Int)? = nil
    var onNavigate: ((T) -> Void)? = nil
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
            List {
                ForEach(items) { item in
                    TodoItemRow<T>(
                        item: item,
                        onToggle: { onToggleComplete(item) },
                        childListCount: childListCountProvider?(item),
                        onNavigate: onNavigate != nil ? { onNavigate?(item) } : nil
                    )
                }
                .onDelete(perform: onDelete)
                .onMove(perform: onMove)
            }
            .listStyle(PlainListStyle())
            .cornerRadius(16)
            .background(Color.clear)
        }
        .padding(.horizontal)
        .padding(.top, 4)
    }
}

#Preview {
    TodoListContainer<Item>(
        items: [
            Item(title: "Sample 1", status: .notStarted, timestamp: Date(), order: 0),
            Item(title: "Sample 2", status: .completed, timestamp: Date(), order: 1)
        ],
        onDelete: { _ in },
        onMove: { _,_  in },
        onToggleComplete: { _ in }
    )
} 