//
//  SearchViewModelTests.swift
//  iTunesSearch
//
//  Created by Beatriz Ogioni on 26/05/26.
//

import Foundation
import Testing
import SwiftData
@testable import iTunesSearch

struct DummyError: Error {}

@MainActor
private func makeInMemoryContext() throws -> ModelContext {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: TrackItemModel.self, configurations: config)
    return ModelContext(container)
}

@MainActor
private func makeSUT() throws -> (vm: SearchViewModel, api: APISpy, router: RouterSpy, context: ModelContext) {
    let api = APISpy()
    let router = RouterSpy()
    let context = try makeInMemoryContext()
    let vm = SearchViewModel(api: api, context: context, router: router)
    return (vm, api, router, context)
}

@MainActor
private func makeTrack(id: String,
                       name: String = "Song",
                       played: Bool = false,
                       inserted: Date = .now) -> TrackItemModel {
    let t = TrackItemModel(id: id, trackName: name, singer: "Artist",
                           musicCover: nil, duration: nil,
                           collectionId: nil, collectionName: nil,
                           previewUrl: nil, insertedAt: inserted)
    t.wasPlayed = played
    return t
}

@MainActor
private func waitUntil(timeout: Duration = .seconds(2), _ condition: () -> Bool) async {
    let start = ContinuousClock.now
    while !condition() {
        if ContinuousClock.now - start > timeout { return }
        try? await Task.sleep(for: .milliseconds(20))
    }
}

@MainActor
@Suite(.serialized)
struct ComputedPropertiesTests {

    @Test func displayedTracksUsesFindedWhenSearching() throws {
        let (vm, _, _, _) = try makeSUT()
        vm.findedMusics = [makeTrack(id: "1")]
        vm.searchText = "x"
        #expect(vm.displayedTracks.count == 1)
        #expect(vm.displayedTracks.first?.id == "1")
    }

    @Test func displayedTracksUsesRecentsWhenSearchEmpty() async throws {
        let (vm, _, _, context) = try makeSUT()
        context.insert(makeTrack(id: "r1", played: true))
        try context.save()
        vm.loadRecents()
        vm.searchText = ""
        #expect(vm.displayedTracks.contains { $0.id == "r1" })
    }

    @Test func canRefreshOnlyWithText() throws {
        let (vm, _, _, _) = try makeSUT()
        vm.searchText = ""
        #expect(vm.canRefresh == false)
        vm.searchText = "x"
        #expect(vm.canRefresh == true)
    }
}

@MainActor
@Suite(.serialized)
struct SearchTests {

    @Test func emptyTermClearsAndSkipsAPI() async throws {
        let (vm, api, _, _) = try makeSUT()
        vm.findedMusics = [makeTrack(id: "stale")]
        vm.searchText = ""
        await vm.search()
        #expect(vm.findedMusics.isEmpty)
        #expect(api.searchCalls.isEmpty)
    }

    @Test func successAppendsAndResetsPage() async throws {
        let (vm, api, _, _) = try makeSUT()
        api.searchResult = .success(.init(items: [makeTrack(id: "1"), makeTrack(id: "2")], hasMore: true))
        vm.searchText = "test"
        await vm.search()
        #expect(vm.findedMusics.count == 2)
        #expect(api.searchCalls.last?.page == 1)
    }

    @Test func percentEncodesTerm() async throws {
        let (vm, api, _, _) = try makeSUT()
        vm.searchText = "foo fighters"
        await vm.search()
        #expect(api.searchCalls.last?.term == "foo%20fighters")
    }

    @Test func errorSetsAlert() async throws {
        let (vm, api, _, _) = try makeSUT()
        api.searchResult = .failure(DummyError())
        vm.searchText = "x"
        await vm.search()
        #expect(vm.showErrorAlert == true)
        #expect(vm.findedMusics.isEmpty)
    }

    @Test func nextPageIncrementsAndAppends() async throws {
        let (vm, api, _, _) = try makeSUT()
        api.searchResult = .success(.init(items: [makeTrack(id: "1")], hasMore: true))
        vm.searchText = "x"
        await vm.search()

        api.searchResult = .success(.init(items: [makeTrack(id: "2")], hasMore: false))
        await vm.nextPage()

        #expect(api.searchCalls.last?.page == 2)
        #expect(vm.findedMusics.count == 2)
    }

    @Test func nextPageBlockedWhenNoMore() async throws {
        let (vm, api, _, _) = try makeSUT()
        api.searchResult = .success(.init(items: [makeTrack(id: "1")], hasMore: false))
        vm.searchText = "x"
        await vm.search()
        let callsBefore = api.searchCalls.count

        await vm.nextPage()
        #expect(api.searchCalls.count == callsBefore)
    }

    @Test func refreshReplacesInsteadOfAppending() async throws {
        let (vm, api, _, _) = try makeSUT()
        vm.findedMusics = [makeTrack(id: "stale")]
        api.searchResult = .success(.init(items: [makeTrack(id: "fresh")], hasMore: false))
        vm.searchText = "x"
        await vm.refresh()
        #expect(vm.findedMusics.map(\.id) == ["fresh"])
    }
}

@MainActor
@Suite(.serialized)
struct PersistenceTests {

    @Test func loadRecentsReturnsOnlyPlayedSortedDesc() throws {
        let (vm, _, _, context) = try makeSUT()
        let old = makeTrack(id: "old", played: true, inserted: .now.addingTimeInterval(-100))
        let new = makeTrack(id: "new", played: true, inserted: .now)
        let notPlayed = makeTrack(id: "np", played: false)
        [old, new, notPlayed].forEach(context.insert)
        try context.save()

        vm.loadRecents()
        #expect(vm.recentTracks.map(\.id) == ["new", "old"])
    }

    @Test func saveInsertsNewTrackAsPlayed() async throws {
        let (vm, _, _, context) = try makeSUT()
        await vm.save(makeTrack(id: "1"))

        let saved = try context.fetch(FetchDescriptor<TrackItemModel>())
        #expect(saved.count == 1)
        #expect(saved.first?.wasPlayed == true)
    }

    @Test func saveDeduplicatesByID() async throws {
        let (vm, _, _, context) = try makeSUT()
        let existing = makeTrack(id: "1", played: false, inserted: .now.addingTimeInterval(-500))
        context.insert(existing)
        try context.save()

        await vm.save(makeTrack(id: "1"))

        let all = try context.fetch(FetchDescriptor<TrackItemModel>())
        #expect(all.count == 1)
        #expect(all.first?.wasPlayed == true)
        #expect(all.first?.insertedAt ?? .distantPast > existing.insertedAt.addingTimeInterval(-1))
    }
}

@MainActor
@Suite(.serialized)
struct NavigationTests {

    @Test func didClickOnSongSavesAndPushes() async throws {
        let (vm, _, router, context) = try makeSUT()
        vm.findedMusics = [makeTrack(id: "1")]
        vm.searchText = "x"

        await vm.didClickOnSong(0)

        guard case let .playScreen(index, tracks)? = router.pushedRoutes.first else {
            Issue.record("Esperava push de .playScreen"); return
        }
        #expect(index == 0)
        #expect(tracks.count == 1)

        let saved = try context.fetch(FetchDescriptor<TrackItemModel>())
        #expect(saved.contains { $0.id == "1" && $0.wasPlayed })
    }

    @Test func didClickInMoreInfoPresentsSheet() throws {
        let (vm, _, router, _) = try makeSUT()
        let track = makeTrack(id: "1")
        vm.didClickInMoreInfo(musicInfo: track)
        #expect(router.presentedSheets.first?.id == "1")
    }
}

@MainActor
@Suite(.serialized)
struct DebounceTests {

    @Test func searchTextTriggersSearchAfterDelay() async throws {
        let (vm, api, _, _) = try makeSUT()
        vm.searchText = "queen"
        await waitUntil { !api.searchCalls.isEmpty }
        #expect(api.searchCalls.contains { $0.term == "queen" })
    }

    @Test func rapidEditsCancelPreviousSearch() async throws {
        let (vm, api, _, _) = try makeSUT()
        vm.searchText = "a"
        vm.searchText = "ab"
        await waitUntil { !api.searchCalls.isEmpty }
        try? await Task.sleep(for: .milliseconds(400))
        #expect(api.searchCalls.count == 1)
        #expect(api.searchCalls.first?.term == "ab")
    }
}
