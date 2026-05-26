//
//  PagedResult.swift
//  iTunesSearch
//
//  Created by Beatriz Ogioni on 26/05/26.
//

import Foundation

struct PagedResult<T> {
    let items: [T]
    let hasMore: Bool
}
