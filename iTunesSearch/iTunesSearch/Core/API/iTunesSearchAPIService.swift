//
//  iTunesSearchAPIService.swift
//  iTunesSearch
//
//  Created by Beatriz Ogioni on 23/05/26.
//

import Foundation

protocol iTunesSearchAPIServicing {
    func searchMusics(term: String, page: Int) async throws -> PagedResult<TrackItemModel>
    func lookupAlbum(collectionId: String) async throws -> [TrackItemModel]
}

enum iTunesSearchAPIEndpoints {
    case search(page: Int, term: String)
    case lookup(collectionId: String)
    
    private var baseEndpoint: String {
        return "https://itunes.apple.com"
    }
    
    private var path: String {
        switch self {
        case let .search(page, term):
            return "/search?term=\(term)&entity=song&media=music&limit=\(page*20)"
        case let .lookup(collectionId):
            return "/lookup?id=\(collectionId)&entity=song"
        }
    }
    
    var endpoint: String {
        return "\(baseEndpoint)\(path)"
    }
}

nonisolated struct iTunesSearchAPI: iTunesSearchAPIServicing {
    private let urlSession: URLSession

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    // That API doesn't support pagination.
    // I opted to implement fake pagination in the service layer – this way,
    // it's not necessary to make code changes in case of switching to another API.
    func searchMusics(term: String, page: Int) async throws -> PagedResult<TrackItemModel> {
        let urlString = iTunesSearchAPIEndpoints.search(page: page, term: term)
        let response: ITunesSearchResponse = try await makeGetRequest(requestUrl: urlString.endpoint)

        let all = response.results.compactMap(TrackItemModel.init)
        let pageSize = 20
        let limit = pageSize * page
        let newItems = Array(all.dropFirst((page - 1) * pageSize))
        let hasMore = all.count == limit && limit < 200

        return PagedResult(items: newItems, hasMore: hasMore)
    }
    
    func lookupAlbum(collectionId: String) async throws -> [TrackItemModel] {
        let urlString = iTunesSearchAPIEndpoints.lookup(collectionId: collectionId)
        let response: ITunesSearchResponse = try await makeGetRequest(requestUrl: urlString.endpoint)
        return response.results
            .filter { $0.wrapperType == .track && $0.kind == .song }
            .compactMap(TrackItemModel.init)
    }
    
    private func makeGetRequest<T: Decodable>(requestUrl: String) async throws -> T {
        guard let url = URL(string: requestUrl) else {
            throw URLError(.badURL)
        }

        let (data, _) = try await urlSession.data(from: url)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Decoding Error: \(error)")
            throw error
        }
    }
}
