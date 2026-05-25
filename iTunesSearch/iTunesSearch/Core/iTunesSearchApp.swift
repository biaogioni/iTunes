//
//  iTunesSearchApp.swift
//  iTunesSearch
//
//  Created by Beatriz Ogioni on 23/05/26.
//

import SwiftUI
import SwiftData

@main
struct iTunesSearchApp: App {
    let container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(for: TrackItemModel.self)
        } catch {
            fatalError("Fail on creating ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            RootView(context: container.mainContext)  
        }
        .modelContainer(for: TrackItemModel.self)
    }
}
