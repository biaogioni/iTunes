//
//  RouterSpy.swift
//  iTunesSearch
//
//  Created by Beatriz Ogioni on 26/05/26.
//

import Foundation
import Testing
@testable import iTunesSearch

@MainActor
final class RouterSpy: Routing {
    private(set) var pushedRoutes: [Route] = []
    private(set) var presentedSheets: [TrackItemModel] = []
    private(set) var dismissedSheets: Int = 0
    
    func push(_ route: Route) {
        pushedRoutes.append(route)
    }
    
    func presentSheet(_ track: TrackItemModel) {
        presentedSheets.append(track)
    }
    
    func dismissSheet() {
        dismissedSheets += 1
    }
}
