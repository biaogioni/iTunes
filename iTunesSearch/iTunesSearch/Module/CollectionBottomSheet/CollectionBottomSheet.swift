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
            Text(viewModel.track.trackName)
                .font(.headline)
            Text(viewModel.track.singer)
                .font(.headline)

            AlbumDetailLabel()
        }
        .padding()
        .presentationDetents([.height(240)])
        .presentationDragIndicator(.visible)
    }
}

struct AlbumDetailLabel: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            Text("view album")
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
        }
    }
}
