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

    private var path: String {
        switch self {
        case .search:  return "/search"
        case .lookup:  return "/lookup"
        }
    }

    private var queryItems: [URLQueryItem] {
        switch self {
        case let .search(page, term):
            return [
                URLQueryItem(name: "term", value: term),
                URLQueryItem(name: "entity", value: "song"),
                URLQueryItem(name: "media", value: "music"),
                URLQueryItem(name: "limit", value: "\(page * 20)")
            ]
        case let .lookup(collectionId):
            return [
                URLQueryItem(name: "id", value: collectionId),
                URLQueryItem(name: "entity", value: "song")
            ]
        }
    }

    var url: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "itunes.apple.com"
        components.path = path
        components.queryItems = queryItems
        return components.url
    }
}

nonisolated struct iTunesSearchAPI: iTunesSearchAPIServicing {
    private let urlSession: URLSession

    private static let pageSize = 20
    private static let maxResults = 200
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    // That API doesn't support pagination.
    // I opted to implement fake pagination in the service layer – this way,
    // it's not necessary to make code changes in case of switching to another API.
    func searchMusics(term: String, page: Int) async throws -> PagedResult<TrackItemModel> {
        let limit = Self.pageSize * page
        let response: ITunesSearchResponse = try await makeGetRequest(
            endpoint: .search(page: page, term: term)
        )
        
        let all = response.results.compactMap(TrackItemModel.init)
        let newItems = Array(all.dropFirst((page - 1) * Self.pageSize))
        let hasMore = all.count >= limit && limit < Self.maxResults
        
        return PagedResult(items: newItems, hasMore: hasMore)
    }
    
    func lookupAlbum(collectionId: String) async throws -> [TrackItemModel] {
        let response: ITunesSearchResponse = try await makeGetRequest(
            endpoint: .lookup(collectionId: collectionId)
        )
        return response.results
            .filter { $0.wrapperType == .track && $0.kind == .song }
            .compactMap(TrackItemModel.init)
    }
    
    private func makeGetRequest<T: Decodable>(endpoint: iTunesSearchAPIEndpoints) async throws -> T {
        guard let url = await endpoint.url else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await urlSession.data(from: url)
        
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw error
        }
    }
}
