//
//  SplashView.swift
//  iTunesSearch
//
//  Created by Beatriz Ogioni on 25/05/26.
//

import SwiftUI

struct SplashView: View {
    @State private var noteScale = 0.85
    @State private var glow = 0.0

    var body: some View {
        ZStack {
            SplashBackground()
            Image(.splashIcon)
                .scaleEffect(noteScale)
                .shadow(color: .cyan.opacity(glow), radius: 24)
        }
        .task {
            withAnimation(.easeOut(duration: 0.8)) {
                noteScale = 1.0
                glow = 0.4
            }
        }
    }
}

struct SplashBackground: View {
    var body: some View {
        ZStack {
            Color(red: 0.004, green: 0.047, blue: 0.055)
            RadialGradient(
                colors: [
                    Color(red: 0.0,  green: 0.20, blue: 0.235),
                    Color(red: 0.0,  green: 0.13, blue: 0.157),
                    Color(red: 0.004, green: 0.02, blue: 0.027)
                ],
                center: UnitPoint(x: 0.62, y: 0.34),
                startRadius: 20,
                endRadius: 520
            )
        }
        .ignoresSafeArea()
    }
}
