//
//  TracksItensModel.swift
//  iTunesSearch
//
//  Created by Beatriz Ogioni on 23/05/26.
//

import Foundation
import SwiftData

@Model
class TracksItensModel {
    @Attribute(.unique) var id: String
    var trackName: String
    var singer: String
    var musicCover: URL?
    
    init(id: String, trackName: String, singer: String, musicCover: URL?) {
        self.id = id
        self.trackName = trackName
        self.singer = singer
        self.musicCover = musicCover
    }
}

extension TracksItensModel {
    convenience init?(from item: ITunesItem) {
        guard let trackId = item.trackId,
              let trackName = item.trackName else { return nil }

        self.init(
            id: String(trackId),
            trackName: trackName,
            singer: item.artistName ?? "Unknown",
            musicCover: item.artworkUrl100
        )
    }
}
