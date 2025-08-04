import SwiftUI

struct TodoListContainer<T: ListItemProtocol>: View where T.Status == TodoStatus {
    let items: [T]
    let onDelete: (IndexSet) -> Void
    let onMove: (IndexSet, Int) -> Void
    let onToggleComplete: (T) -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
            List {
                ForEach(items) { item in
                    TodoItemRow<T>(item: item) {
                        onToggleComplete(item)
                    }
                }
                .onDelete(perform: onDelete)
                .onMove(perform: onMove)
            }
            .listStyle(PlainListStyle())
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