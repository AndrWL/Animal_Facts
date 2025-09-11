//
//  AnimalFactsApp.swift
//  AnimalFacts
//
//  Created by ANDRII LEBEDIEV on 10.09.2025.
//

import ComposableArchitecture
import SwiftUI

@main
struct AnimalFactsApp: App {
    var body: some Scene {
        WindowGroup {
            CategoriesView(
                store: Store(initialState: CategoriesListFeature.State()) {
                    CategoriesListFeature()
                }
            )
            .appTheme(.main)
        }
    }
}
