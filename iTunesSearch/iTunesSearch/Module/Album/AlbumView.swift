//
//  AlbumView.swift
//  iTunesSearch
//
//  Created by Beatriz Ogioni on 25/05/26.
//

import SwiftUI
import SwiftData

struct AlbumView: View {
    @State private var viewModel: AlbumViewModel
    
    init(musicReference: TrackItemModel, context: ModelContext, router: Router) {
        _viewModel = State(wrappedValue: AlbumViewModel(context: context, musicReference: musicReference, router: router))
    }

    var body: some View {
        CachedImage(data: viewModel.musicReference.coverData, url: viewModel.musicReference.musicCover)
        .frame(width: 120, height: 120)
        .aspectRatio(1, contentMode: .fit)
        .clipShape(.rect(cornerRadius: 28))
        
        VStack(spacing: 6) {
            Text(viewModel.musicReference.collectionName ?? "")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.text03)
            Text(viewModel.musicReference.singer)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.text03)
        }
            .padding(16)
        
        List(viewModel.albumSongs.enumerated(), id: \.element.id) { index, item in
            SongRow(trackName: item.trackName,
                    singer: item.singer,
                    coverURL: item.musicCover,
                    coverData: item.coverData,
                    hasMoreOptions: false,
                    moreOptionsClicked: nil
            )
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
            .contentShape(Rectangle())
            .onTapGesture {
                viewModel.didClickOnSong(index)
            }
        }
        .listStyle(.plain)
        .errorAlert(isPresented: $viewModel.showErrorAlert)
        .task {
            Task {
                await viewModel.loadAlbum()
            }
        }
    }
}
