//
//  AlbumModel.swift
//  iTunesSearch
//
//  Created by Beatriz Ogioni on 26/05/26.
//

import Foundation
import SwiftData

@Model
final class AlbumModel {
    @Attribute(.unique) var id: String
    var collectionName: String
    var artistName: String
    var artworkURL: URL?
    var coverData: Data?
    var insertedAt: Date

    @Relationship(deleteRule: .nullify, inverse: \TrackItemModel.album)
    var tracks: [TrackItemModel] = []

    init(id: String, collectionName: String, artistName: String,
         artworkURL: URL? = nil, coverData: Data? = nil,
         insertedAt: Date = .now, tracks: [TrackItemModel] = []) {
        self.id = id
        self.collectionName = collectionName
        self.artistName = artistName
        self.artworkURL = artworkURL
        self.coverData = coverData
        self.insertedAt = insertedAt
        self.tracks = tracks
    }
}
