//
//  APISpy.swift
//  iTunesSearch
//
//  Created by Beatriz Ogioni on 26/05/26.
//

import Foundation
import Testing
@testable import iTunesSearch

@MainActor
final class APISpy: iTunesSearchAPIServicing {
    var searchResult: Result<PagedResult<TrackItemModel>, Error> = .success(.init(items: [], hasMore: false))
    var lookupResult: Result<[TrackItemModel], Error> = .success([])
    private(set) var searchCalls: [(term: String, page: Int)] = []
    private(set) var lookupCalls: [String] = []

    func searchMusics(term: String, page: Int) async throws -> PagedResult<TrackItemModel> {
        searchCalls.append((term, page))
        return try searchResult.get()
    }
    func lookupAlbum(collectionId: String) async throws -> [TrackItemModel] {
        lookupCalls.append(collectionId)
        return try lookupResult.get()
    }
}
