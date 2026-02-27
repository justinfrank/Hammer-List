//
//  ListOverview.swift
//  Hammer List
//
//  Created by Justin Frank on [Current Date]
//

import SwiftUI
import SwiftData

struct ListOverviewView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\ItemList.order, order: .forward)]) private var lists: [ItemList]
    @State private var showingAddProjectModal = false
    @State private var showingAddListSheet = false
    @State private var editMode: EditMode = .inactive

    // MARK: - Helpers

    private var rootLists: [ItemList] {
        lists.filter { $0.isRoot }
    }

    /// Walks up parentItem → parentList chain to find the root-level ItemList ancestor.
    private func rootAncestor(of list: ItemList) -> ItemList? {
        guard !list.isRoot else { return nil }
        var current: ItemList = list
        var seen = Set<UUID>()
        while !current.isRoot {
            guard !seen.contains(current.id) else { return nil }
            seen.insert(current.id)
            guard let parent = current.parentItems.first?.parentList else { return nil }
            current = parent
        }
        return current
    }

    private func metaString(for project: ItemList) -> String {
        let itemCount = project.items.count
        let listCount = lists.filter { !$0.isRoot && rootAncestor(of: $0)?.id == project.id }.count
        let itemLabel = itemCount == 1 ? "item" : "items"
        let listLabel = listCount == 1 ? "list" : "lists"
        return "\(itemCount) \(itemLabel) / \(listCount) \(listLabel)"
    }

    // MARK: - Body

    var body: some View {
        VStack {
            if rootLists.isEmpty {
                ContentUnavailableView(
                    "No Projects Yet",
                    systemImage: "list.bullet.rectangle",
                    description: Text("Create your first project to get started")
                )
            } else {
                List {
                    ForEach(rootLists) { project in
                        NavigationLink(value: project) {
                            projectRowView(project)
                        }
                    }
                    .onDelete(perform: deleteProjects)
                    .onMove(perform: moveProjects)
                }
                .environment(\.editMode, $editMode)
            }
        }
        .navigationTitle("Projects")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        showingAddProjectModal = true
                    } label: {
                        Label("New Project", systemImage: "folder.badge.plus")
                    }
                    Button {
                        showingAddListSheet = true
                    } label: {
                        Label("New List", systemImage: "list.bullet")
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddProjectModal) {
            AddListModal()
        }
        .sheet(isPresented: $showingAddListSheet) {
            CreateListInProjectSheet()
        }
    }

    // MARK: - Row Views

    @ViewBuilder
    private func projectRowView(_ project: ItemList) -> some View {
        HStack {
            Text(project.name)
                .font(AppTokens.Typography.headline)
            Spacer()
            Text(metaString(for: project))
                .font(AppTokens.Typography.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 2)
    }

    // MARK: - Private Methods

    private func deleteProjects(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(rootLists[index])
            }
            try? modelContext.save()
        }
    }

    private func moveProjects(from source: IndexSet, to destination: Int) {
        var mutableLists = rootLists
        mutableLists.move(fromOffsets: source, toOffset: destination)
        for (index, list) in mutableLists.enumerated() {
            list.order = index
        }
        try? modelContext.save()
    }
}
