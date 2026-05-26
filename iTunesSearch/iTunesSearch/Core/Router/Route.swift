//
//  Route.swift
//  iTunesSearch
//
//  Created by Beatriz Ogioni on 23/05/26.
//

import SwiftUI

enum Route: Hashable {
    case playScreen(Int, [TrackItemModel])
    case albumScreen(TrackItemModel)
}

protocol Routing {
    func push(_ route: Route)
    func presentSheet(_ track: TrackItemModel)
    func dismissSheet()
}

@Observable
final class Router: Routing {
    var path = NavigationPath()
    var presentedSheet: TrackItemModel?

    func push(_ route: Route) {
        path.append(route)
    }
    
    func presentSheet(_ item: TrackItemModel) {
        presentedSheet = item
    }

    func dismissSheet() {
        presentedSheet = nil
    }

    func pop() {
        guard !path.isEmpty else { return }
           path.removeLast()
    }

    func popToRoot() {
        path = NavigationPath()
    }
}
