//
//  CreateListInProjectSheet.swift
//  Hammer List
//

import SwiftUI
import SwiftData

struct CreateListInProjectSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: [SortDescriptor(\ItemList.order)]) private var allLists: [ItemList]
    private var projects: [ItemList] { allLists.filter { $0.isRoot } }

    @State private var selectedProject: ItemList? = nil
    @State private var listName: String = ""
    @FocusState private var nameFieldFocused: Bool

    var body: some View {
        NavigationView {
            Form {
                Section("Project") {
                    ForEach(projects) { project in
                        Button {
                            selectedProject = project
                        } label: {
                            HStack {
                                Text(project.name)
                                Spacer()
                                if selectedProject?.id == project.id {
                                    Image(systemName: "checkmark").foregroundColor(.accentColor)
                                }
                            }
                        }
                        .foregroundColor(.primary)
                    }
                    if projects.isEmpty {
                        Text("No projects yet — create a project first.")
                            .foregroundColor(.secondary)
                            .font(AppTokens.Typography.caption)
                    }
                }

                if selectedProject != nil {
                    Section("List Name") {
                        TextField("Enter list name", text: $listName)
                            .focused($nameFieldFocused)
                            .onSubmit { createList() }
                    }
                }
            }
            .navigationTitle("New List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") { createList() }
                        .disabled(selectedProject == nil || listName.trimmingCharacters(in: .whitespaces).isEmpty)
                        .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private func createList() {
        guard let project = selectedProject else { return }
        let trimmed = listName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        let maxOrder = (project.items.map(\.order).max() ?? -1)
        let containerItem = Item(title: trimmed, timestamp: Date(), order: maxOrder + 1)
        project.items.append(containerItem)

        let newList = ItemList(name: trimmed)
        newList.order = 0
        modelContext.insert(newList)
        containerItem.childLists.append(newList)

        try? modelContext.save()
        dismiss()
    }
}
