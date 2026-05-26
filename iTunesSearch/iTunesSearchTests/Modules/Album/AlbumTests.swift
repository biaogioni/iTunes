//
//  AlbumTests.swift
//  iTunesSearch
//
//  Created by Beatriz Ogioni on 26/05/26.
//

import Foundation
import Testing
import SwiftData
@testable import iTunesSearch

@MainActor
private func makeInMemoryContext() throws -> ModelContext {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try ModelContainer(
        for: TrackItemModel.self,
        AlbumModel.self,
        configurations: config
    )
    return ModelContext(container)
}

@MainActor
private func track(_ id: String,
                   collectionId: Int? = nil,
                   collectionName: String? = nil) -> TrackItemModel {
    TrackItemModel(id: id, trackName: "T\(id)", singer: "Artist",
                   musicCover: nil, duration: nil,
                   collectionId: collectionId, collectionName: collectionName,
                   previewUrl: nil)
}

@MainActor
private func makeSUT(reference: TrackItemModel) throws
-> (vm: AlbumViewModel, api: APISpy, router: RouterSpy, context: ModelContext) {
    let api = APISpy()
    let router = RouterSpy()
    let context = try makeInMemoryContext()
    let vm = AlbumViewModel(api: api, context: context, musicReference: reference, router: router)
    return (vm, api, router, context)
}

@MainActor
@Suite(.serialized)
struct LoadAlbumNetworkTests {
    @Test func noCollectionIdSkipsEverything() async throws {
        let ref = track("ref", collectionId: nil)
        let (vm, api, _, _) = try makeSUT(reference: ref)
        await vm.loadAlbum()
        #expect(api.lookupCalls.isEmpty)
        #expect(vm.albumSongs.isEmpty)
    }

    @Test func fetchesAndPopulatesSongs() async throws {
        let ref = track("ref", collectionId: 5000, collectionName: "Album X")
        let (vm, api, _, _) = try makeSUT(reference: ref)
        api.lookupResult = .success([track("1"), track("2"), track("3")])

        await vm.loadAlbum()

        #expect(api.lookupCalls == ["5000"])
        #expect(vm.albumSongs.count == 3)
    }

    @Test func persistsAlbumAfterFetch() async throws {
        let ref = track("ref", collectionId: 5000, collectionName: "Album X")
        let (_, _, _, context) = try makeSUT(reference: ref)
        let api = APISpy(); api.lookupResult = .success([track("1")])
        let vm2 = AlbumViewModel(api: api, context: context,
                                 musicReference: ref, router: RouterSpy())

        await vm2.loadAlbum()

        let albums = try context.fetch(FetchDescriptor<AlbumModel>())
        #expect(albums.count == 1)
        #expect(albums.first?.id == "5000")
    }

    @Test func emptyResultDoesNotPersist() async throws {
        let ref = track("ref", collectionId: 5000)
        let (vm, api, _, context) = try makeSUT(reference: ref)
        api.lookupResult = .success([])

        await vm.loadAlbum()

        let albums = try context.fetch(FetchDescriptor<AlbumModel>())
        #expect(albums.isEmpty)
        #expect(vm.albumSongs.isEmpty)
    }

    @Test func apiErrorSetsAlert() async throws {
        let ref = track("ref", collectionId: 5000)
        let (vm, api, _, context) = try makeSUT(reference: ref)
        api.lookupResult = .failure(DummyError())

        await vm.loadAlbum()

        #expect(vm.showErrorAlert == true)
        #expect(vm.albumSongs.isEmpty)
        let albums = try context.fetch(FetchDescriptor<AlbumModel>())
        #expect(albums.isEmpty)
    }
}

@MainActor
@Suite(.serialized)
struct LoadAlbumCacheTests {

    @Test func usesCachedAlbumWithoutCallingAPI() async throws {
        let ref = track("ref", collectionId: 5000, collectionName: "Cached")
        let (vm, api, _, context) = try makeSUT(reference: ref)

        let cachedTrack = track("c1")
        context.insert(cachedTrack)
        let album = AlbumModel(id: "5000", collectionName: "Cached",
                               artistName: "Artist", artworkURL: nil)
        album.tracks = [cachedTrack]
        context.insert(album)
        try context.save()

        await vm.loadAlbum()

        #expect(api.lookupCalls.isEmpty)
        #expect(vm.albumSongs.map(\.id) == ["c1"])
    }

    @Test func cacheHitRefreshesInsertedAt() async throws {
        let ref = track("ref", collectionId: 5000)
        let (vm, _, _, context) = try makeSUT(reference: ref)

        let old = Date.now.addingTimeInterval(-1000)
        let album = AlbumModel(id: "5000", collectionName: "C",
                               artistName: "A", artworkURL: nil)
        album.insertedAt = old
        album.tracks = [track("c1")]
        context.insert(album)
        try context.save()

        await vm.loadAlbum()

        let refreshed = try #require(
            try context.fetch(FetchDescriptor<AlbumModel>()).first
        )
        #expect(refreshed.insertedAt > old)
    }
}

@MainActor
@Suite(.serialized)
struct ReconcileTests {

    @Test func reusesExistingTrackInstance() async throws {
        let ref = track("ref", collectionId: 5000)
        let (vm, api, _, context) = try makeSUT(reference: ref)

        let existing = track("1")
        existing.trackName = "PERSISTIDO"
        context.insert(existing)
        try context.save()

        let fresh = track("1"); fresh.trackName = "DA_API"
        api.lookupResult = .success([fresh, track("2")])

        await vm.loadAlbum()

        let song1 = try #require(vm.albumSongs.first { $0.id == "1" })
        #expect(song1.trackName == "PERSISTIDO")
        #expect(vm.albumSongs.count == 2)
    }

    @Test func keepsApiTrackWhenNotCached() async throws {
        let ref = track("ref", collectionId: 5000)
        let (vm, api, _, _) = try makeSUT(reference: ref)
        api.lookupResult = .success([track("99")])

        await vm.loadAlbum()

        #expect(vm.albumSongs.first?.id == "99")
    }
}

@MainActor
@Suite(.serialized)
struct AlbumNavigationTests {

    @Test func didClickOnSongPushesPlayScreen() async throws {
        let ref = track("ref", collectionId: 5000)
        let (vm, api, router, _) = try makeSUT(reference: ref)
        api.lookupResult = .success([track("1"), track("2")])
        await vm.loadAlbum()

        vm.didClickOnSong(1)

        guard case let .playScreen(index, songs)? = router.pushedRoutes.first else {
            Issue.record("Esperava push de .playScreen"); return
        }
        #expect(index == 1)
        #expect(songs.count == 2)
    }

    @Test func didClickPushesCurrentAlbumSongs() throws {
        let ref = track("ref", collectionId: 5000)
        let (vm, _, router, _) = try makeSUT(reference: ref)
        vm.didClickOnSong(0)
        guard case let .playScreen(_, songs)? = router.pushedRoutes.first else {
            Issue.record("Esperava push"); return
        }
        #expect(songs.isEmpty)
    }
}
