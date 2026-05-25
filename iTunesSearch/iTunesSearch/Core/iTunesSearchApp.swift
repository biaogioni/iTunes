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
    var body: some Scene {
        WindowGroup {
            RootView()  
        }
        .modelContainer(for: TracksItensModel.self)
    }
}
