//
//  Route.swift
//  iTunesSearch
//
//  Created by Beatriz Ogioni on 23/05/26.
//

import SwiftUI

enum Route: Hashable {
    case playScreen(ITunesItem)
}

@Observable
final class Router {
    var path = NavigationPath()
    var presentedSheet: ITunesItem?

    func push(_ route: Route) {
        path.append(route)
    }
    
    func presentSheet(_ item: ITunesItem) {
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
