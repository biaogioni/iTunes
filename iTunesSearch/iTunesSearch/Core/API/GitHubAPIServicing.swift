//
//  iTunesSearchAPIService.swift
//  iTunesSearch
//
//  Created by Beatriz Ogioni on 23/05/26.
//

import Foundation

protocol iTunesSearchAPIServicing {
    func searchMusics(term: String, page: Int) async throws -> ITunesSearchResponse
}

enum iTunesSearchAPIEndpoints {
    case find(page: Int, term: String)
    
    private var baseEndpoint: String {
        return "https://itunes.apple.com/search?"
    }
    
    private var path: String {
        switch self {
        case let .find(page, term):
            return "term=\(term)&entity=song&media=music&limit=20&offset=\(page*20)"
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
    
    func searchMusics(term: String, page: Int) async throws -> ITunesSearchResponse {
        let urlString = iTunesSearchAPIEndpoints.find(page: page, term: term)
        return try await makeGetRequest(requestUrl: urlString.endpoint)
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
