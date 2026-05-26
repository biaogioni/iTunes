//
//  CollectionBottomSheetViewModel.swift
//  iTunesSearch
//
//  Created by Beatriz Ogioni on 24/05/26.
//

import Foundation

@Observable
final class CollectionBottomSheetViewModel {
    private let router: Router
    let track: TrackItemModel
    
    init(track: TrackItemModel, router: Router) {
        self.router = router
        self.track = track
    }
    
    func viewAlbum() {
        router.dismissSheet()
        router.push(.albumScreen(track))
    }
}
