//
//  RootView.swift
//  iTunesSearch
//
//  Created by Beatriz Ogioni on 23/05/26.
//

import SwiftUI

struct RootView: View {
    @State private var router = Router()

    var body: some View {
        NavigationStack(path: $router.path) {
            SearchView(router: router)
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .playScreen(let item):
                        PlayerView(musicInfo: item, router: router)
                    }
                }
        }
        .sheet(item: $router.presentedSheet) { item in
            CollectionBottomSheet(track: item, router: router)
                .presentationDetents([.height(150)])
                .presentationDragIndicator(.visible)
        }
        .environment(router)
    }
}
