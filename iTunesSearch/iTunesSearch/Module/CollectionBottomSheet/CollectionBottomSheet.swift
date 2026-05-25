//
//  CollectionBottomSheet.swift
//  iTunesSearch
//
//  Created by Beatriz Ogioni on 24/05/26.
//

import SwiftUI

struct CollectionBottomSheet: View {
    @State private var viewModel: CollectionBottomSheetViewModel
    @Environment(\.dismiss) private var dismiss

    init(track: TrackItemModel, router: Router) {
        _viewModel = State(wrappedValue: CollectionBottomSheetViewModel(track: track))
    }

    var body: some View {
        VStack() {
            VStack(spacing: 6) {
                Text(viewModel.track.trackName)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.text03)
                Text(viewModel.track.singer)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.text03)
            }
                .padding(16)
            AlbumDetailLabel()
                .padding(.horizontal, 24)
        }
        .presentationDetents([.height(140)])
        .presentationDragIndicator(.visible)
    }
}

struct AlbumDetailLabel: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(.setlist)
                .frame(width: 24, height: 24)
                .padding(.leading, 8)
                .padding(.vertical, 16)
            Text("View album")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.text03)
            Spacer()
        }
    }
}
