//
//  iTunesSearchAPITests.swift
//  iTunesSearch
//
//  Created by Beatriz Ogioni on 26/05/26.
//

import Foundation
import Testing
@testable import iTunesSearch

@MainActor
@Suite("Endpoints")
struct EndpointTests {
    @Test func searchURL() {
        #expect(iTunesSearchAPIEndpoints.search(page: 3, term: "beatles").endpoint
            == "https://itunes.apple.com/search?term=beatles&entity=song&media=music&limit=60")
    }
    @Test func lookupURL() {
        #expect(iTunesSearchAPIEndpoints.lookup(collectionId: "42").endpoint
            == "https://itunes.apple.com/lookup?id=42&entity=song")
    }
}

@MainActor
@Suite(.serialized)
struct SearchMusicsTests {
    @Test func decodesFirstPage() async throws {
        MockURLProtocol.requestHandler = { (okResponse(for: $0), makeITunesJSON(validCount: 20)) }
        let sut = iTunesSearchAPI(urlSession: makeMockSession())
        let result = try await sut.searchMusics(term: "test", page: 1)
        #expect(result.items.count == 20)
    }

    @Test func hasMoreWhenFullPageUnderCap() async throws {
        MockURLProtocol.requestHandler = { (okResponse(for: $0), makeITunesJSON(validCount: 20)) }
        let sut = iTunesSearchAPI(urlSession: makeMockSession())
        let result = try await sut.searchMusics(term: "test", page: 1)
        #expect(result.hasMore == true)
    }

    @Test func noMoreOnPartialPage() async throws {
        MockURLProtocol.requestHandler = { (okResponse(for: $0), makeITunesJSON(validCount: 15)) }
        let sut = iTunesSearchAPI(urlSession: makeMockSession())
        let result = try await sut.searchMusics(term: "test", page: 1)
        #expect(result.hasMore == false)
        #expect(result.items.count == 15)
    }

    @Test func noMoreAtTwoHundredCap() async throws {
        MockURLProtocol.requestHandler = { (okResponse(for: $0), makeITunesJSON(validCount: 200)) }
        let sut = iTunesSearchAPI(urlSession: makeMockSession())
        let result = try await sut.searchMusics(term: "test", page: 10)
        #expect(result.hasMore == false)
    }

    @Test func fakePaginationDropsPreviousPages() async throws {
        // page 2 -> dropFirst(20) de 40 itens -> 20
        MockURLProtocol.requestHandler = { (okResponse(for: $0), makeITunesJSON(validCount: 40)) }
        let sut = iTunesSearchAPI(urlSession: makeMockSession())
        let result = try await sut.searchMusics(term: "test", page: 2)
        #expect(result.items.count == 20)
        #expect(result.hasMore == true)
    }

    @Test func invalidItemsAreDroppedBeforeHasMoreCalc() async throws {
        MockURLProtocol.requestHandler = { (okResponse(for: $0), makeITunesJSON(validCount: 20, invalidCount: 5)) }
        let sut = iTunesSearchAPI(urlSession: makeMockSession())
        let result = try await sut.searchMusics(term: "test", page: 1)
        #expect(result.items.count == 20)
        #expect(result.hasMore == true)
    }

    @Test func emptyResults() async throws {
        MockURLProtocol.requestHandler = { (okResponse(for: $0), makeITunesJSON(validCount: 0)) }
        let sut = iTunesSearchAPI(urlSession: makeMockSession())
        let result = try await sut.searchMusics(term: "test", page: 1)
        #expect(result.items.isEmpty)
        #expect(result.hasMore == false)
    }

    @Test func throwsOnInvalidJSON() async throws {
        MockURLProtocol.requestHandler = { (okResponse(for: $0), Data("{ broken".utf8)) }
        let sut = iTunesSearchAPI(urlSession: makeMockSession())
        await #expect(throws: (any Error).self) {
            try await sut.searchMusics(term: "test", page: 1)
        }
    }

    @Test func propagatesNetworkError() async throws {
        MockURLProtocol.requestHandler = { _ in throw URLError(.notConnectedToInternet) }
        let sut = iTunesSearchAPI(urlSession: makeMockSession())
        await #expect(throws: URLError.self) {
            try await sut.searchMusics(term: "test", page: 1)
        }
    }

    @Test func sendsTermInURL() async throws {
        MockURLProtocol.requestHandler = { req in
            #expect(req.url?.absoluteString.contains("term=queen") == true)
            return (okResponse(for: req), makeITunesJSON(validCount: 1))
        }
        let sut = iTunesSearchAPI(urlSession: makeMockSession())
        _ = try await sut.searchMusics(term: "queen", page: 1)
    }
}

@MainActor
@Suite(.serialized)
struct MappingTests {

    @Test func mapsCoreFields() async throws {
        MockURLProtocol.requestHandler = { (okResponse(for: $0), makeITunesJSON(validCount: 1)) }
        let sut = iTunesSearchAPI(urlSession: makeMockSession())
        let item = try #require(try await sut.searchMusics(term: "x", page: 1).items.first)

        #expect(item.id == "1000")
        #expect(item.trackName == "Track 0")
        #expect(item.singer == "Artist 0")
        #expect(item.collectionId == 5000)
        #expect(item.collectionName == "Album")
        #expect(item.duration == 200) // 200000ms / 1000
    }

    @Test func resizesCoverArtworkTo1000() async throws {
        MockURLProtocol.requestHandler = { (okResponse(for: $0), makeITunesJSON(validCount: 1)) }
        let sut = iTunesSearchAPI(urlSession: makeMockSession())
        let item = try #require(try await sut.searchMusics(term: "x", page: 1).items.first)
        #expect(item.musicCover?.absoluteString == "https://example.com/img/1000x1000bb.jpg")
    }

    @Test func defaultsSingerToUnknownWhenArtistMissing() async throws {
        let json = Data("""
        { "resultCount": 1, "results": [
            { "trackId": 1, "trackName": "Solo", "artworkUrl100": null }
        ]}
        """.utf8)
        MockURLProtocol.requestHandler = { (okResponse(for: $0), json) }
        let sut = iTunesSearchAPI(urlSession: makeMockSession())
        let item = try #require(try await sut.searchMusics(term: "x", page: 1).items.first)
        #expect(item.singer == "Unknown")
        #expect(item.musicCover == nil)
    }
}

@MainActor
@Suite(.serialized)
struct LookupAlbumTests {

    @Test func returnsAllValidTracks() async throws {
        MockURLProtocol.requestHandler = { (okResponse(for: $0), makeITunesJSON(validCount: 12, invalidCount: 3)) }
        let sut = iTunesSearchAPI(urlSession: makeMockSession())
        let tracks = try await sut.lookupAlbum(collectionId: "5000")
        #expect(tracks.count == 12) // os 3 inválidos foram descartados
    }

    @Test func sendsCollectionIdInURL() async throws {
        MockURLProtocol.requestHandler = { req in
            #expect(req.url?.absoluteString.contains("id=5000") == true)
            return (okResponse(for: req), makeITunesJSON(validCount: 1))
        }
        let sut = iTunesSearchAPI(urlSession: makeMockSession())
        _ = try await sut.lookupAlbum(collectionId: "5000")
    }

    @Test func throwsOnDecodingFailure() async throws {
        MockURLProtocol.requestHandler = { (okResponse(for: $0), Data("not json".utf8)) }
        let sut = iTunesSearchAPI(urlSession: makeMockSession())
        await #expect(throws: (any Error).self) {
            _ = try await sut.lookupAlbum(collectionId: "5000")
        }
    }
}

private func makeMockSession() -> URLSession {
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    return URLSession(configuration: config)
}

private func okResponse(for request: URLRequest) -> HTTPURLResponse {
    HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
}

private func itemJSON(index i: Int, valid: Bool = true) -> String {
    let idLine = valid ? "\"trackId\": \(1000 + i)," : ""
    let nameLine = valid ? "\"trackName\": \"Track \(i)\"," : ""
    return """
    {
        \(idLine)
        \(nameLine)
        "artistName": "Artist \(i)",
        "collectionId": 5000,
        "collectionName": "Album",
        "artworkUrl100": "https://example.com/img/100x100bb.jpg",
        "previewUrl": "https://example.com/preview/\(i).m4a",
        "trackTimeMillis": 200000,
        "releaseDate": "2020-01-01T08:00:00Z"
    }
    """
}

private func makeITunesJSON(validCount: Int, invalidCount: Int = 0) -> Data {
    var entries = (0..<validCount).map { itemJSON(index: $0) }
    entries += (0..<invalidCount).map { itemJSON(index: 9000 + $0, valid: false) }
    let body = entries.joined(separator: ",")
    let total = validCount + invalidCount
    return Data("{ \"resultCount\": \(total), \"results\": [\(body)] }".utf8)
}
