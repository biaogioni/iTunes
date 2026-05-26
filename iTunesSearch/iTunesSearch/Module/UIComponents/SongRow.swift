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
    
    let hasMoreOptions: Bool
    let moreOptionsClicked: (() -> Void)?

    var body: some View {
        HStack(spacing: 16) {
            AsyncImage(url: coverURL) { phase in
                switch phase {
                case .success(let image):
                    image.resizable()
                default:
                    Rectangle().fill(.quaternary)
                }
            }
            .frame(width: 52, height: 52)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(trackName)
                    .font(.system(size: 16, weight: .medium))
                    .lineLimit(1)
                    .foregroundStyle(Color.text03)
                Text(singer)
                    .font(.system(size: 12, weight: .regular))
                    .lineLimit(1)
                    .foregroundStyle(Color.text00)
            }
            Spacer(minLength: 0)
            if hasMoreOptions {
                Button {
                    moreOptionsClicked?()
                } label: {
                    Image(.ellipsis)
                        .foregroundStyle(Color.element03)
                        .frame(width: 20, height: 20)
                }
                .buttonStyle(.borderless)
            }
        }
    }
}
