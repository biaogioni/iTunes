//
//  RouterTests.swift
//  iTunesSearch
//
//  Created by Beatriz Ogioni on 26/05/26.
//

import Foundation
import SwiftUI
import Testing
@testable import iTunesSearch

@MainActor
private func track(_ id: String) -> TrackItemModel {
    TrackItemModel(id: id, trackName: "T\(id)", singer: "A", musicCover: nil,
                   duration: nil, collectionId: nil, collectionName: nil, previewUrl: nil)
}

@MainActor
@Suite("Router - navigation stack")
struct RouterStackTests {

    @Test func startsEmpty() {
        let sut = Router()
        #expect(sut.path.isEmpty)
        #expect(sut.path.count == 0)
        #expect(sut.presentedSheet == nil)
    }

    @Test func pushIncrementsPath() {
        let sut = Router()
        sut.push(.albumScreen(track("1")))
        #expect(sut.path.count == 1)
        #expect(sut.path.isEmpty == false)
    }

    @Test func multiplePushesStack() {
        let sut = Router()
        sut.push(.playScreen(0, [track("1")]))
        sut.push(.albumScreen(track("2")))
        sut.push(.playScreen(1, [track("3")]))
        #expect(sut.path.count == 3)
    }

    @Test func popRemovesLast() {
        let sut = Router()
        sut.push(.albumScreen(track("1")))
        sut.push(.albumScreen(track("2")))
        sut.pop()
        #expect(sut.path.count == 1)
    }

    @Test func popOnEmptyIsNoOp() {
        let sut = Router()
        sut.pop()
        #expect(sut.path.count == 0)
        #expect(sut.path.isEmpty)
    }

    @Test func popDownToEmpty() {
        let sut = Router()
        sut.push(.albumScreen(track("1")))
        sut.pop()
        #expect(sut.path.isEmpty)
        sut.pop()
        #expect(sut.path.isEmpty)
    }

    @Test func popToRootClearsEverything() {
        let sut = Router()
        sut.push(.albumScreen(track("1")))
        sut.push(.playScreen(0, [track("2")]))
        sut.push(.albumScreen(track("3")))
        sut.popToRoot()
        #expect(sut.path.isEmpty)
        #expect(sut.path.count == 0)
    }

    @Test func popToRootOnEmptyIsNoOp() {
        let sut = Router()
        sut.popToRoot()
        #expect(sut.path.isEmpty)
    }
}

@MainActor
@Suite("Router - sheet")
struct RouterSheetTests {

    @Test func presentSetsSheet() {
        let sut = Router()
        sut.presentSheet(track("42"))
        #expect(sut.presentedSheet?.id == "42")
    }

    @Test func presentOverwritesPrevious() {
        let sut = Router()
        sut.presentSheet(track("1"))
        sut.presentSheet(track("2"))
        #expect(sut.presentedSheet?.id == "2")
    }

    @Test func dismissClearsSheet() {
        let sut = Router()
        sut.presentSheet(track("1"))
        sut.dismissSheet()
        #expect(sut.presentedSheet == nil)
    }

    @Test func dismissWhenNothingPresentedIsNoOp() {
        let sut = Router()
        sut.dismissSheet()
        #expect(sut.presentedSheet == nil)
    }
}

@MainActor
@Suite("Router - stack & sheet independence")
struct RouterIndependenceTests {

    @Test func pushDoesNotAffectSheet() {
        let sut = Router()
        sut.presentSheet(track("s"))
        sut.push(.albumScreen(track("p")))
        #expect(sut.presentedSheet?.id == "s")
        #expect(sut.path.count == 1)
    }

    @Test func dismissDoesNotAffectStack() {
        let sut = Router()
        sut.push(.albumScreen(track("p")))
        sut.presentSheet(track("s"))
        sut.dismissSheet()
        #expect(sut.path.count == 1)
        #expect(sut.presentedSheet == nil)
    }

    @Test func popToRootDoesNotClearSheet() {
        let sut = Router()
        sut.push(.albumScreen(track("p")))
        sut.presentSheet(track("s"))
        sut.popToRoot()
        #expect(sut.path.isEmpty)
        #expect(sut.presentedSheet?.id == "s")
    }
}
