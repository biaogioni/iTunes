//
//  TracksItensModel.swift
//  iTunesSearch
//
//  Created by Beatriz Ogioni on 23/05/26.
//

import Foundation
import SwiftData

@Model
final class TrackItemModel {
    @Attribute(.unique) var id: String
    var trackName: String
    var singer: String
    
    var musicCover: URL?
    @Attribute(.externalStorage) var coverData: Data?
    
    var duration: TimeInterval?
    var collectionId: Int?
    var collectionName: String?
    var previewUrl: URL?
    
    var insertedAt: Date
    
    var wasPlayed: Bool = false     
    var album: AlbumModel?
    
    init(id: String,
         trackName: String,
         singer: String,
         musicCover: URL?,
         duration: TimeInterval?,
         collectionId: Int?,
         collectionName: String?,
         previewUrl: URL?,
         insertedAt: Date = .now,
         wasPlayed: Bool = false,
         album: AlbumModel? = nil) {
        self.id = id
        self.trackName = trackName
        self.singer = singer
        self.musicCover = musicCover
        self.duration = duration
        self.collectionId = collectionId
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
            musicCover: Self.resizeCover(from: item.artworkUrl100, size: 1000),
            duration: item.duration,
            collectionId: item.collectionId,
            collectionName: item.collectionName,
            previewUrl: item.previewUrl
        )
    }
    
    private static func resizeCover(from url: URL?, size: Int) -> URL? {
       guard let base = url?.absoluteString else { return nil }
       return URL(string: base.replacingOccurrences(of: "100x100bb",
                                                     with: "\(size)x\(size)bb"))
   }
}
