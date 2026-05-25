//
//  PlayerView.swift
//  iTunesSearch
//
//  Created by Beatriz Ogioni on 23/05/26.
//

import SwiftUI
import SwiftData
struct PlayerView: View {
    @State private var viewModel: PlayerViewModel
    
    init(musicInfo: ITunesItem, router: Router) {
        _viewModel = State(wrappedValue: PlayerViewModel(musicInfo: musicInfo, router: router))
    }
 
    var body: some View {
        VStack(spacing: 0) {
            artwork
                .padding(.top, 24)
 
            Spacer()
 
            trackInfo
                .padding(.horizontal, 32)
 
            progress
                .padding(.horizontal, 32)
                .padding(.top, 16)
 
            controls
                .padding(.top, 28)
                .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(viewModel.musicInfo.collectionName ?? "")
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.moreInfo()
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(.white.opacity(0.12), in: .circle)
                }
            }
        }
        .toolbarBackground(.black, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
 
    private var artwork: some View {
        AsyncImage(url: viewModel.musicInfo.artworkUrl100) { phase in
            switch phase {
            case .success(let image):
                image.resizable().scaledToFill()
            default:
                Rectangle().fill(.quaternary)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .clipShape(.rect(cornerRadius: 28))
        .padding(.horizontal, 56)
        .shadow(color: .black.opacity(0.4), radius: 20, y: 10)
    }
 
    private var trackInfo: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.musicInfo.trackName ?? "")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                    .lineLimit(1)
 
                Text(viewModel.musicInfo.artistName ?? "")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
 
            Spacer()
 
            Button {
                viewModel.toggleRepeat()
            } label: {
                Image(systemName: "repeat")
                    .font(.title2)
//                    .foregroundStyle(viewModel.isRepeating ? .blue : .white)
            }
        }
    }
    
    private var progress: some View {
        VStack(spacing: 6) {
            Slider(value: $viewModel.currentTime,
                   in: 0...(viewModel.musicInfo.duration ?? 30),
                   onEditingChanged: { editing in
                       if !editing { viewModel.seek(to: viewModel.currentTime) }
                   })
            .tint(.white)
 
            HStack {
                Text(viewModel.currentTime.asPlaybackTime)
                Spacer()
//                Text("-" + viewModel.remainingTime.asPlaybackTime)
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
    }
    
    private var controls: some View {
        HStack(spacing: 48) {
            Button {
                viewModel.previous()
            } label: {
                Image(systemName: "backward.fill")
                    .font(.title)
                    .foregroundStyle(.white)
            }
 
            Button {
                viewModel.togglePlay()
            } label: {
                Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                    .frame(width: 80, height: 80)
                    .background(.white.opacity(0.18), in: .circle)
            }
 
            Button {
                viewModel.next()
            } label: {
                Image(systemName: "forward.fill")
                    .font(.title)
                    .foregroundStyle(.white)
            }
        }
    }
}
 
private extension Double {
    /// Formata segundos em "m:ss"
    var asPlaybackTime: String {
        guard isFinite, self >= 0 else { return "0:00" }
        let total = Int(self)
        return String(format: "%d:%02d", total / 60, total % 60)
    }
}
