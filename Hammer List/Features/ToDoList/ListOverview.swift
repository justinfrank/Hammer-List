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
    @State private var showingAddListModal = false
    @State private var editMode: EditMode = .inactive
    
    var body: some View {
        VStack {
            if lists.isEmpty {
                ContentUnavailableView(
                    "No Lists Yet",
                    systemImage: "list.bullet.rectangle",
                    description: Text("Create your first list to get started")
                )
            } else {
                List {
                    ForEach(lists) { list in
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
                    .onDelete(perform: deleteLists)
                    .onMove(perform: moveLists)
                }
                .environment(\.editMode, $editMode)
            }
        }
        .navigationTitle("All Lists")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            // ToolbarItem(placement: .navigationBarLeading) {
            //     if !lists.isEmpty {
            //         EditButton()
            //             .onTapGesture {
            //                 withAnimation {
            //                     editMode = editMode == .active ? .inactive : .active
            //                 }
            //             }
            //     }
            // }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("New List") {
                    showingAddListModal = true
                }
            }
        }
        .sheet(isPresented: $showingAddListModal) {
            AddListModal()
        }
    }
    
    // MARK: - Private Methods
    
    private func deleteLists(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(lists[index])
            }
            
            do {
                try modelContext.save()
            } catch {
                print("Error deleting lists: \(error)")
            }
        }
    }
    
    private func moveLists(from source: IndexSet, to destination: Int) {
        withAnimation {
            // Create a mutable copy of the lists array
            var mutableLists = Array(lists)
            
            // Move the items in the array
            mutableLists.move(fromOffsets: source, toOffset: destination)
            
            // Update the order property for all affected lists
            for (index, list) in mutableLists.enumerated() {
                list.order = index
            }
            
            do {
                try modelContext.save()
            } catch {
                print("Error reordering lists: \(error)")
            }
        }
    }
}