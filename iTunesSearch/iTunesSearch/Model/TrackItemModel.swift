//
//  TracksItensModel.swift
//  iTunesSearch
//
//  Created by Beatriz Ogioni on 23/05/26.
//

import Foundation
import SwiftData

@Model
class TrackItemModel {
    @Attribute(.unique) var id: String
    var trackName: String
    var singer: String
    var musicCover: URL?
    
    var duration: TimeInterval?
    var collectionName: String?
    var previewUrl: URL?
    
    var insertedAt: Date
    
    init(id: String,
         trackName: String,
         singer: String,
         musicCover: URL?,
         duration: TimeInterval?,
         collectionName: String?,
         previewUrl: URL?,
         insertedAt: Date = .now) {
        self.id = id
        self.trackName = trackName
        self.singer = singer
        self.musicCover = musicCover
        self.duration = duration
        self.collectionName = collectionName
        self.previewUrl = previewUrl
        self.insertedAt = insertedAt
    }
}

extension TrackItemModel {
    convenience init?(from item: ITunesItem) {
        guard let trackId = item.trackId,
              let trackName = item.trackName else { return nil }

        self.init(
            id: String(trackId),
            trackName: trackName,
            singer: item.artistName ?? "Unknown",
            musicCover: item.artworkUrl100,
            duration: item.duration,
            collectionName: item.collectionName,
            previewUrl: item.previewUrl
        )
    }
}
