//
//  OrderedRouterSpy.swift
//  iTunesSearch
//
//  Created by Beatriz Ogioni on 26/05/26.
//

import Foundation
import Testing
@testable import iTunesSearch

@MainActor
private func track(_ id: String) -> TrackItemModel {
    TrackItemModel(id: id, trackName: "T\(id)", singer: "A", musicCover: nil,
                   duration: nil, collectionId: nil, collectionName: nil, previewUrl: nil)
}

@MainActor
@Suite("CollectionBottomSheetViewModel")
struct CollectionBottomSheetViewModelTests {

    @Test func storesTrack() {
        let vm = CollectionBottomSheetViewModel(track: track("1"), router: RouterSpy())
        #expect(vm.track.id == "1")
    }

    @Test func viewAlbumDismissesAndPushesAlbum() {
        let router = RouterSpy()
        let vm = CollectionBottomSheetViewModel(track: track("1"), router: router)

        vm.viewAlbum()

        #expect(router.dismissedSheets == 1)
        #expect(router.pushedRoutes.count == 1)

        guard case let .albumScreen(t) = router.pushedRoutes.first else {
            Issue.record("Esperava .albumScreen"); return
        }
        #expect(t.id == "1")
    }
}
