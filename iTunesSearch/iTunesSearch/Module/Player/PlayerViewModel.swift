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
    private var musicPlaylist: [TrackItemModel]
    private var currentMusicIndex: Int {
        didSet {
            playingMusic = musicPlaylist[safe: currentMusicIndex]
            loadCurrentTrack()
        }
    }
    
    var currentTime: Double = 0
    var isPlaying = false

    private var player: AVPlayer?
    
    private let router: Routing
    
    var playingMusic: TrackItemModel?
    
    var remainingTime: Double? {
        guard let duration = playingMusic?.duration else { return nil }
        return max(duration - currentTime, 0)
    }
    
    var canGoNext: Bool {
        currentMusicIndex < musicPlaylist.count - 1
    }

    var canGoPrevious: Bool {
        currentMusicIndex > 0
    }
    
    var isRepeating: Bool = false
    
    init(currentMusicIndex: Int, musicPlaylist: [TrackItemModel], router: Routing) {
        self.currentMusicIndex = currentMusicIndex
        self.musicPlaylist = musicPlaylist
        self.playingMusic = musicPlaylist[safe: currentMusicIndex]
        self.router = router
    }
    
    private func loadCurrentTrack() {
        guard let preview = playingMusic?.previewUrl else { return }

        player?.pause()
        
        // Preview playback requires network (remote stream); offline
        // detection will be here in future interactions. Failures surface
        // through the error alert rather than failing silently.
        player = AVPlayer(url: preview)
        currentTime = 0
        addTimeObserver()

        if isPlaying {
            player?.play()
        }
    }

    private func addTimeObserver() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: 600)
        player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            MainActor.assumeIsolated {
                self?.currentTime = time.seconds
            }
        }
    }

    func setupPlayer() {
        loadCurrentTrack()
    }
    
    func moreInfo() {
        guard let playingMusic else { return }
        router.presentSheet(playingMusic)
    }
    
    func togglePlay() {
        isPlaying ? player?.pause() : player?.play()
        isPlaying.toggle()
    }

    func seek(to seconds: Double) {
        player?.seek(to: CMTime(seconds: seconds, preferredTimescale: 600))
    }

    func next() {
        guard currentMusicIndex < musicPlaylist.count - 1 else { return }
        currentMusicIndex += 1
    }
    
    func previous() {
        guard currentMusicIndex > 0 else { return }
        currentMusicIndex -= 1
    }
    
    func toggleRepeat() {
        isRepeating = !isRepeating
    }
}
