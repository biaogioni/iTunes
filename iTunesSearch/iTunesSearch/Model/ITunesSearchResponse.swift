//
//  ITunesSearchResponse.swift
//  iTunesSearch
//
//  Created by Beatriz Ogioni on 23/05/26.
//

import Foundation
 
nonisolated struct ITunesSearchResponse: Codable {
    let resultCount: Int
    let results: [ITunesItem]
}

nonisolated struct ITunesItem: Codable, Hashable {
    let wrapperType: WrapperType?
    let kind: Kind?
 
    let artistId: Int?
    let collectionId: Int?
    let trackId: Int?
    let amgArtistId: Int?
 
    let artistName: String?
    let collectionName: String?
    let trackName: String?
    
    let collectionCensoredName: String?
    let trackCensoredName: String?
 
    let artistViewUrl: URL?
    let collectionViewUrl: URL?
    let trackViewUrl: URL?
    
    let previewUrl: URL?
    let artworkUrl30: URL?
    let artworkUrl60: URL?
    let artworkUrl100: URL?
 
    let collectionPrice: Double?
    let trackPrice: Double?
    let trackRentalPrice: Double?
    let collectionHdPrice: Double?
    let trackHdPrice: Double?
    let trackHdRentalPrice: Double?
    let currency: String?
 
    let releaseDate: Date?
    let collectionExplicitness: Explicitness?
    let trackExplicitness: Explicitness?
    let trackTimeMillis: Int?
    let country: String?
    let primaryGenreName: String?
    let contentAdvisoryRating: String?
    let copyright: String?
 
    let discCount: Int?
    let discNumber: Int?
    let trackCount: Int?
    let trackNumber: Int?
 
    let shortDescription: String?
    let longDescription: String?
    let description: String?
}

extension ITunesItem: Identifiable {
    var id: Int { trackId ?? 0 }
}
 
extension ITunesItem {
 
    enum WrapperType: String, Codable {
        case track
        case audiobook
        case collection
        case artist
        case unknown
 
        init(from decoder: Decoder) throws {
            let raw = try decoder.singleValueContainer().decode(String.self)
            self = WrapperType(rawValue: raw) ?? .unknown
        }
    }
 
    enum Kind: String, Codable {
        case book
        case album
        case coachedAudio = "coached-audio"
        case featureMovie = "feature-movie"
        case interactiveBooklet = "interactive-booklet"
        case musicVideo = "music-video"
        case pdfPodcast = "pdf podcast"
        case podcastEpisode = "podcast-episode"
        case softwarePackage = "software-package"
        case song
        case tvEpisode = "tv-episode"
        case artist
        case unknown
 
        init(from decoder: Decoder) throws {
            let raw = try decoder.singleValueContainer().decode(String.self)
            self = Kind(rawValue: raw) ?? .unknown
        }
    }
 
    enum Explicitness: String, Codable {
        case explicit
        case cleaned
        case notExplicit
        case unknown
 
        init(from decoder: Decoder) throws {
            let raw = try decoder.singleValueContainer().decode(String.self)
            self = Explicitness(rawValue: raw) ?? .unknown
        }
    }
}
 
extension ITunesItem {
    nonisolated var duration: TimeInterval? {
        trackTimeMillis.map { TimeInterval($0) / 1000 }
    }
    
    var bestDescription: String? {
        longDescription ?? description ?? shortDescription
    }
}
