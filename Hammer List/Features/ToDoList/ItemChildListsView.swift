import SwiftUI

struct ItemChildListsView: View {
    let item: Item

    // Sorted once on appear and refreshed when the relationship count changes,
    // avoiding a repeated O(n log n) sort on every body render.
    @State private var childLists: [ItemList] = []

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
        .onAppear {
            childLists = item.childLists.sorted { $0.order < $1.order }
        }
        .onChange(of: item.childLists.count) {
            childLists = item.childLists.sorted { $0.order < $1.order }
        }
    }
}
