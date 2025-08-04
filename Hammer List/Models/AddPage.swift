//
//  AppPage.swift
//  Hammer List
//
//  Created by Justin Frank on 7/15/25.
//

import Foundation

enum AppPage: String, CaseIterable, Identifiable, Hashable {
    case list // Main list page
    case settings = "Settings"
    case about = "About"

    var id: String { self.rawValue }
}