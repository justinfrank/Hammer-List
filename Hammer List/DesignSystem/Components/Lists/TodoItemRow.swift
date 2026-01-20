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
                .foregroundColor(textColor)
                .fontWeight(fontWeight)
            
            Spacer()
            
            Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .shortened))
                .font(.caption)
                .foregroundColor(timestampColor)
        }
    }
    
    // MARK: - Computed Properties for Styling
    
    private var textColor: Color {
        switch item.status {
        case .notStarted:
            return LightTheme.brand
        case .inProgress:
            return .orange // Or whatever color you prefer for in-progress
        case .completed:
            return .gray
        }
    }
    
    private var fontWeight: Font.Weight {
        switch item.status {
        case .notStarted:
            return .regular
        case .inProgress:
            return .medium // Make in-progress items slightly bolder
        case .completed:
            return .regular
        }
    }
    
    private var timestampColor: Color {
        switch item.status {
        case .notStarted:
            return .secondary
        case .inProgress:
            return .orange.opacity(0.7) // Match the text color but muted
        case .completed:
            return .gray.opacity(0.7)
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