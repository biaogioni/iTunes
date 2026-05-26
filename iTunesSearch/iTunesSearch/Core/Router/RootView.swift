//
//  RootView.swift
//  iTunesSearch
//
//  Created by Beatriz Ogioni on 23/05/26.
//

import SwiftUI
import SwiftData

struct RootView: View {
    @State private var router = Router()
    @State private var isActive = false
    
    private let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }

    var body: some View {
        if isActive {
            NavigationStack(path: $router.path) {
                SearchView(context: context, router: router)
                    .navigationDestination(for: Route.self) { route in
                        switch route {
                        case .playScreen(let index, let musicPlaylist):
                            PlayerView(currentMusicIndex: index, musicPlaylist: musicPlaylist, router: router)
                        case .albumScreen(let item):
                            AlbumView(musicReference: item, context: context, router: router)
                        }
                    }
            }
            .sheet(item: $router.presentedSheet) { item in
                CollectionBottomSheet(track: item, router: router)
            }
            .environment(router)
        } else {
            SplashView()
                .task {
                    try? await Task.sleep(for: .seconds(1.5))
                    withAnimation { isActive = true }
                }
        }
    }
}
