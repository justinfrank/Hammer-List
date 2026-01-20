//
//  AppDetailView.swift
//  Hammer List
//
//  Created by Justin Frank on 8/3/25.
//

import SwiftUI

struct AppDetailView: View {
    let selectedPage: AppPage?
    
    var body: some View {
        Group {
            switch selectedPage {
            case .home:
                ListOverviewView()
            case .list:
                // Your existing list view
                Text("Individual List View")
            case .settings:
                Text("Settings View - Coming Soon")
            case .about:
                Text("About View - Coming Soon")
            case .none:
                Text("Select a page from the sidebar")
            }
        }
    }
}