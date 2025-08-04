//
//  ContentView.swift
//  Hammer List
//
//  Created by Justin Frank on 7/15/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedPage: AppPage? = .list

    var body: some View {
        NavigationSplitView {
            AppSidebarView(selectedPage: $selectedPage)
        } detail: {
            AppDetailView(selectedPage: selectedPage)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}