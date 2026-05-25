//
//  PlayerViewModel.swift
//  iTunesSearch
//
//  Created by Beatriz Ogioni on 24/05/26.
//

import Foundation
import SwiftData
import AVFoundation
import Observation

@MainActor
@Observable
final class PlayerViewModel {
    var musicInfo: ITunesItem
    var currentTime: Double = 0
    var isPlaying = false

    private let player: AVPlayer
    
    private let api: iTunesSearchAPI
    private let router: Router

    init(musicInfo: ITunesItem, api: iTunesSearchAPI = iTunesSearchAPI(), router: Router) {
        self.musicInfo = musicInfo
        self.api = api
        self.router = router
        
        player = AVPlayer(url: musicInfo.previewUrl!)

        let interval = CMTime(seconds: 0.5, preferredTimescale: 600)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.currentTime = time.seconds
        }
    }
    
    func buildMusicList() {
        
    }
    
    func moreInfo() {
        router.presentSheet(musicInfo)
    }
    
    func didClickOnSong(_ item: ITunesItem, into context: ModelContext) {
//        save(item, into: context)
//        router.push(.playScreen(item))
    }

    func togglePlay() {
        isPlaying ? player.pause() : player.play()
        isPlaying.toggle()
    }

    func seek(to seconds: Double) {
        player.seek(to: CMTime(seconds: seconds, preferredTimescale: 600))
    }

    func next() {}
    func previous() {}
    func toggleRepeat() {}
    
}
