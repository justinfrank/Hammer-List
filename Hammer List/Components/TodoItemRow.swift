import SwiftUI

struct TodoItemRow<T: ListItemProtocol>: View where T.Status == TodoStatus {
    let item: T
    let onToggle: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onToggle) {
                StatusCheckbox(status: item.status)
                    .frame(width: 18, height: 18)
            }
            .buttonStyle(PlainButtonStyle())
            Text(item.title)
                .strikethrough(item.status == .completed)
                .foregroundColor(item.status == .completed ? .gray : .primary)
            Spacer()
            Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .shortened))
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        TodoItemRow<Item>(item: Item(title: "Not Started", status: .notStarted, timestamp: Date())) {}
        TodoItemRow<Item>(item: Item(title: "In Progress", status: .inProgress, timestamp: Date())) {}
        TodoItemRow<Item>(item: Item(title: "Completed", status: .completed, timestamp: Date())) {}
    }
} 
