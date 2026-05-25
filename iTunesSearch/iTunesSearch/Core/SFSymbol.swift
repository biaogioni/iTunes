//
//  SFSymbol.swift
//  iTunesSearch
//
//  Created by Beatriz Ogioni on 25/05/26.
//

import SwiftUI

// enum created to avoid leaving strings scattered throughout the code.
// gains in centralization for future replacement.
enum SFSymbol: String {
    case play = "play.fill"
    case pause = "pause.fill"
    case forward = "forward.fill"
    case backward = "backward.fill"
    case repeatTrack = "repeat"
    case chevronLeft = "chevron.left"
    case ellipsis
    case magnifyingglass
    case xmarkCircleFill = "xmark.circle.fill"
}

extension Image {
    init(symbol: SFSymbol) {
        self.init(systemName: symbol.rawValue)
    }
}
