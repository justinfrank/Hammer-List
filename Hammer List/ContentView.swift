//
//  ContentView.swift
//  Hammer List
//
//  Created by Justin Frank on 7/15/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedPage: AppPage? = .home

    var body: some View {
        NavigationStack {
            // Start with the ListOverviewView as the root
            ListOverviewView()
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Menu {
                            Button("All Lists") {
                                selectedPage = .home
                            }
                            Button("Settings") {
                                selectedPage = .settings
                            }
                            Button("About") {
                                selectedPage = .about
                            }
                        } label: {
                            Image(systemName: "line.horizontal.3")
                                .foregroundColor(.primary)
                        }
                    }
                }
                .navigationDestination(for: ItemList.self) { list in
                    ListDetailView(list: list)
                }
                .sheet(isPresented: .constant(selectedPage != .home && selectedPage != nil)) {
                    NavigationView {
                        Group {
                            switch selectedPage {
                            case .settings:
                                Text("Settings View - Coming Soon")
                                    .navigationTitle("Settings")
                            case .about:
                                Text("About View - Coming Soon")
                                    .navigationTitle("About")
                            default:
                                EmptyView()
                            }
                        }
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Done") {
                                    selectedPage = .home
                                }
                            }
                        }
                    }
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Item.self, ItemList.self], inMemory: true)
}