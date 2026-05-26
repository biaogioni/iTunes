//
//  PlayerViewModelTests.swift
//  iTunesSearch
//
//  Created by Beatriz Ogioni on 26/05/26.
//

import Foundation
import Testing
@testable import iTunesSearch

@MainActor
private func track(_ id: String,
                   duration: TimeInterval? = nil,
                   preview: URL? = nil) -> TrackItemModel {
    TrackItemModel(id: id, trackName: "T\(id)", singer: "A", musicCover: nil,
                   duration: duration, collectionId: nil, collectionName: nil,
                   previewUrl: preview)
}

@MainActor
private func makeSUT(index: Int = 0,
                     playlist: [TrackItemModel]) -> (vm: PlayerViewModel, router: RouterSpy) {
    let router = RouterSpy()
    let vm = PlayerViewModel(currentMusicIndex: index, musicPlaylist: playlist, router: router)
    return (vm, router)
}

@MainActor
@Suite("PlayerViewModel - init")
struct PlayerInitTests {
    @Test func setsPlayingMusicAndDefaults() {
        let (vm, _) = makeSUT(index: 1, playlist: [track("0"), track("1")])
        #expect(vm.playingMusic?.id == "1")
        #expect(vm.isPlaying == false)
        #expect(vm.isRepeating == false)
        #expect(vm.currentTime == 0)
    }

    @Test func outOfRangeIndexGivesNilTrack() {
        let (vm, _) = makeSUT(index: 5, playlist: [track("0")])
        #expect(vm.playingMusic == nil)
    }

    @Test func doesNotCreatePlayerOnInit() {
        let (vm, _) = makeSUT(playlist: [track("0", preview: URL(string: "https://e.com/0.m4a"))])
        #expect(vm.isPlaying == false)
    }
}

@MainActor
@Suite("PlayerViewModel - navigation")
struct PlayerNavigationTests {

    @Test func boundaryFlags() {
        let (first, _) = makeSUT(index: 0, playlist: [track("0"), track("1"), track("2")])
        #expect(first.canGoPrevious == false)
        #expect(first.canGoNext == true)

        let (last, _) = makeSUT(index: 2, playlist: [track("0"), track("1"), track("2")])
        #expect(last.canGoNext == false)
        #expect(last.canGoPrevious == true)
    }

    @Test func singleItemHasNoNeighbors() {
        let (vm, _) = makeSUT(playlist: [track("0")])
        #expect(vm.canGoNext == false)
        #expect(vm.canGoPrevious == false)
    }

    @Test func nextAdvances() {
        let (vm, _) = makeSUT(index: 0, playlist: [track("0"), track("1")])
        vm.next()
        #expect(vm.playingMusic?.id == "1")
        #expect(vm.canGoNext == false)
        #expect(vm.canGoPrevious == true)
    }

    @Test func nextAtLastIsNoOp() {
        let (vm, _) = makeSUT(index: 1, playlist: [track("0"), track("1")])
        vm.next()
        #expect(vm.playingMusic?.id == "1")
    }

    @Test func previousGoesBack() {
        let (vm, _) = makeSUT(index: 1, playlist: [track("0"), track("1")])
        vm.previous()
        #expect(vm.playingMusic?.id == "0")
        #expect(vm.canGoPrevious == false)
    }

    @Test func previousAtFirstIsNoOp() {
        let (vm, _) = makeSUT(index: 0, playlist: [track("0"), track("1")])
        vm.previous()
        #expect(vm.playingMusic?.id == "0")
    }
}

@MainActor
@Suite("PlayerViewModel - toggles")
struct PlayerToggleTests {
    @Test func togglePlayFlipsIsPlaying() {
        let (vm, _) = makeSUT(playlist: [track("0")])
        #expect(vm.isPlaying == false)
        vm.togglePlay(); #expect(vm.isPlaying == true)
        vm.togglePlay(); #expect(vm.isPlaying == false)
    }

    @Test func toggleRepeatFlips() {
        let (vm, _) = makeSUT(playlist: [track("0")])
        #expect(vm.isRepeating == false)
        vm.toggleRepeat(); #expect(vm.isRepeating == true)
        vm.toggleRepeat(); #expect(vm.isRepeating == false)
    }
}

@MainActor
@Suite("PlayerViewModel - remainingTime")
struct PlayerRemainingTimeTests {

    @Test func nilWhenNoDuration() {
        let (vm, _) = makeSUT(playlist: [track("0")])
        #expect(vm.remainingTime == nil)
    }

    @Test func subtractsCurrentTime() {
        let (vm, _) = makeSUT(playlist: [track("0", duration: 100)])
        vm.currentTime = 30
        #expect(vm.remainingTime == 70)
    }

    @Test func clampsToZero() {
        let (vm, _) = makeSUT(playlist: [track("0", duration: 100)])
        vm.currentTime = 150
        #expect(vm.remainingTime == 0)
    }
}

// MARK: - moreInfo / routing

@MainActor
@Suite("PlayerViewModel - moreInfo")
struct PlayerMoreInfoTests {

    @Test func presentsCurrentTrack() {
        let (vm, router) = makeSUT(playlist: [track("0")])
        vm.moreInfo()
        #expect(router.presentedSheets.first?.id == "0")
    }

    @Test func noOpWhenNoTrack() {
        let (vm, router) = makeSUT(index: 0, playlist: [])
        vm.moreInfo()
        #expect(router.presentedSheets.isEmpty)
    }
}

@MainActor
@Suite("PlayerViewModel - currentTime reset")
struct PlayerCurrentTimeResetTests {

    // ⚠️ Cria um AVPlayer real (URL bogus, sem play()) — não toca a rede, mas é o
    // único teste que instancia AVFoundation.
    @Test func resetsToZeroWhenTrackHasPreview() {
        let (vm, _) = makeSUT(index: 0, playlist: [
            track("0", preview: URL(string: "https://example.com/0.m4a")),
            track("1", preview: URL(string: "https://example.com/1.m4a"))
        ])
        vm.currentTime = 42
        vm.next()
        #expect(vm.currentTime == 0)
    }

    @Test func leavesStaleTimeWhenNoPreview() {
        let (vm, _) = makeSUT(index: 0, playlist: [track("0"), track("1")])
        vm.currentTime = 30
        vm.next()
        #expect(vm.currentTime == 30)
    }
}
