//
//  AlbumViewModel.swift
//  iTunesSearch
//
//  Created by Beatriz Ogioni on 25/05/26.
//

import Foundation
import SwiftData

@MainActor
@Observable
final class AlbumViewModel {
    private let api: iTunesSearchAPI
    private let router: Router
    
    private var isLoading = false
    var musicReference: TrackItemModel
    var albumSongs: [TrackItemModel] = []
    
    init(api: iTunesSearchAPI = iTunesSearchAPI(), musicReference: TrackItemModel, router: Router) {
        self.api = api
        self.router = router
        self.musicReference = musicReference
    }
    
    func didClickOnSong(_ item: Int) {
        router.push(.playScreen(item, albumSongs))
    }
    
    func loadPage() async {
        guard let collectionId = musicReference.collectionId else { return }
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        
        do {
            albumSongs = try await api.lookupAlbum(collectionId: String(collectionId))
        } catch {
            print("api error: \(error)")
        }
    }
}
