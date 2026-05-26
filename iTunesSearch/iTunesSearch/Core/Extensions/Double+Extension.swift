//
//  Double+Extension.swift
//  iTunesSearch
//
//  Created by Beatriz Ogioni on 25/05/26.
//

import SwiftUI

extension Double {
   var asPlaybackTime: String {
       guard isFinite, self >= 0 else { return "0:00" }
       let total = Int(self)
       return String(format: "%d:%02d", total / 60, total % 60)
   }
}
