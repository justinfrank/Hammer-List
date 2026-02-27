import SwiftUI

struct ItemChildListsView: View {
    let item: Item

    private var childLists: [ItemList] {
        item.childLists.sorted { $0.order < $1.order }
    }

    var body: some View {
        List {
            ForEach(childLists) { list in
                NavigationLink(value: list) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(list.name)
                            .font(.headline)
                        Text("\(list.items.count) items")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .navigationTitle(item.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
