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
    private let api: iTunesSearchAPIServicing
    private let router: Routing
    private let context: ModelContext

    private var isLoading = false
    var musicReference: TrackItemModel
    var albumSongs: [TrackItemModel] = []
    
    var showErrorAlert = false

    init(api: iTunesSearchAPIServicing = iTunesSearchAPI(),
         context: ModelContext,
         musicReference: TrackItemModel,
         router: Routing) {
        self.api = api
        self.router = router
        self.context = context
        self.musicReference = musicReference
    }

    func didClickOnSong(_ item: Int) {
        router.push(.playScreen(item, albumSongs))
    }

    func loadAlbum() async {
        guard let collectionId = musicReference.collectionId else { return }
        let id = String(collectionId)

        let descriptor = FetchDescriptor<AlbumModel>(
            predicate: #Predicate { $0.id == id }
        )

        if let existing = try? context.fetch(descriptor).first {
            existing.insertedAt = .now
            albumSongs = existing.tracks
            try? context.save()
            return
        }

        await loadPage()
        guard !albumSongs.isEmpty else { return }

        let album = makeAlbum(id: id, from: albumSongs)
        album.tracks = albumSongs
        context.insert(album)
        try? context.save()
    }

    private func makeAlbum(id: String, from tracks: [TrackItemModel]) -> AlbumModel {
        AlbumModel(
            id: id,
            collectionName: musicReference.collectionName ?? "",
            artistName: musicReference.singer,
            artworkURL: musicReference.musicCover
        )
    }

    private func loadPage() async {
        guard let collectionId = musicReference.collectionId else { return }
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let fetched = try await api.lookupAlbum(collectionId: String(collectionId))
            albumSongs = fetched.map { reconcile($0) }
        } catch {
            showErrorAlert = true
        }
    }
    
    private func reconcile(_ track: TrackItemModel) -> TrackItemModel {
        let id = track.id
        let descriptor = FetchDescriptor<TrackItemModel>(
            predicate: #Predicate { $0.id == id }
        )
        if let existing = try? context.fetch(descriptor).first {
            return existing
        }
        return track
    }
}
