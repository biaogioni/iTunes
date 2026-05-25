//
//  SongRow.swift
//  iTunesSearch
//
//  Created by Beatriz Ogioni on 23/05/26.
//

import SwiftUI


struct SongRow: View {
    let trackName: String
    let singer: String
    let coverURL: URL?

    var body: some View {
            HStack(spacing: 12) {
                AsyncImage(url: coverURL) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable()
                    default:
                        Rectangle().fill(.quaternary)
                    }
                }
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 6))

                VStack(alignment: .leading, spacing: 2) {
                    Text(trackName)
                        .font(.body)
                        .lineLimit(1)
                    Text(singer)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
            }
            .contentShape(Rectangle())
        }
}
