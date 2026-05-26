//
//  AppImages.swift
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
    case chevronLeft = "chevron.left"
    case ellipsis
    case magnifyingglass
    case xmarkCircleFill = "xmark.circle.fill"
}

enum AppImage: String {
    case setlist = "ic-setlist"
    case playOnRepeat = "ic-play-on-repeat"
    case forward = "ic-forward-bar-fill"
    case backward = "ic-backward-bar-fill"
}

extension Image {
    init(_ symbol: SFSymbol) {
        self.init(systemName: symbol.rawValue)
    }
    
    init(_ asset: AppImage) {
        self.init(asset.rawValue)
    }
}
