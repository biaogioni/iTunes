//
//  Collection+Extension.swift
//  iTunesSearch
//
//  Created by Beatriz Ogioni on 25/05/26.
//

import Foundation

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
