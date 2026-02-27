import SwiftUI

struct TodoItemRow<T: ListItemProtocol>: View where T.Status == TodoStatus {
    let item: T
    let onToggle: () -> Void
    var childListCount: Int? = nil
    var onNavigate: (() -> Void)? = nil
    var onAddChildList: (() -> Void)? = nil

    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.colorScheme) private var systemScheme: ColorScheme

    private var theme: AppTheme {
        let effective = themeManager.followSystem ? systemScheme : themeManager.override.colorScheme
        return themeManager.theme(for: effective)
    }
    
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

            if let count = childListCount {
                Button(action: { onNavigate?() }) {
                    ListItemIndicator(count: count)
                }
                .buttonStyle(PlainButtonStyle())
            }

        }
        .contextMenu {
            if let addChildList = onAddChildList {
                Button {
                    addChildList()
                } label: {
                    Label("Add List", systemImage: "list.bullet.indent")
                }
            }
        }
    }
    
    // MARK: - Computed Properties for Styling
    
    private var textColor: Color {
        switch item.status {
        case .notStarted:
            return theme.brand
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
    
}

#Preview {
    VStack(spacing: 12) {
        TodoItemRow<Item>(item: Item(title: "Not Started", status: .notStarted, timestamp: Date())) {}
        TodoItemRow<Item>(item: Item(title: "In Progress", status: .inProgress, timestamp: Date())) {}
        TodoItemRow<Item>(item: Item(title: "Completed", status: .completed, timestamp: Date())) {}
    }
}