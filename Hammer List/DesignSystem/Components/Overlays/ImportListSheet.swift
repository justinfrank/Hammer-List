//
//  ImportListSheet.swift
//  Hammer List
//

import SwiftUI
import SwiftData

struct ImportListSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var themeManager: ThemeManager

    let targetList: ItemList

    @Query(sort: \ItemList.name) private var allLists: [ItemList]
    @State private var importAsSeparateItems = false

    private var importableLists: [ItemList] {
        allLists.filter { $0.id != targetList.id }
    }

    var body: some View {
        NavigationView {
            List {
                Section {
                    Toggle("Import as separate items", isOn: $importAsSeparateItems)
                } footer: {
                    Text(importAsSeparateItems
                         ? "Items will be added directly to this list."
                         : "The list will be linked as a shared nested list. Changes sync across all projects.")
                        .font(AppTokens.Typography.caption)
                }

                Section("Lists") {
                    ForEach(importableLists) { list in
                        Button {
                            if importAsSeparateItems {
                                importAsFlatItems(from: list)
                            } else {
                                importAsNestedList(from: list)
                            }
                            dismiss()
                        } label: {
                            HStack {
                                Text(list.name)
                                Spacer()
                                Text("\(list.items.count) items")
                                    .font(AppTokens.Typography.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
            }
            .navigationTitle("Import List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    /// Links the source list as a shared nested list under a new container item in the target list.
    /// The source list's items are not copied — both locations reference the same list, so
    /// status changes (completions etc.) are reflected everywhere it appears.
    private func importAsNestedList(from sourceList: ItemList) {
        let maxOrder = (targetList.items.map(\.order).max() ?? -1)
        let newItem = Item(
            title: sourceList.name,
            timestamp: Date(),
            order: maxOrder + 1
        )
        targetList.items.append(newItem)
        newItem.childLists.append(sourceList)
        try? modelContext.save()
    }

    /// Alternate: copies source items directly into the target list as flat items.
    private func importAsFlatItems(from sourceList: ItemList) {
        let maxOrder = (targetList.items.map(\.order).max() ?? -1)
        for (index, sourceItem) in sourceList.items.sorted(by: { $0.order < $1.order }).enumerated() {
            let copy = Item(
                title: sourceItem.title,
                status: sourceItem.status,
                timestamp: Date(),
                order: maxOrder + 1 + index
            )
            targetList.items.append(copy)
        }
        try? modelContext.save()
    }
}
