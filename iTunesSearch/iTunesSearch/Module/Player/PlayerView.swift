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
    
    init(currentMusicIndex: Int, musicPlaylist: [TrackItemModel], router: Routing) {
        _viewModel = State(wrappedValue: PlayerViewModel(currentMusicIndex: currentMusicIndex, musicPlaylist: musicPlaylist, router: router))
    }
 
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            CachedImage(data: viewModel.playingMusic?.coverData, url: viewModel.playingMusic?.musicCover)
                .aspectRatio(1, contentMode: .fit)
                .clipShape(.rect(cornerRadius: 28))
                .padding(.horizontal, 56)
            
            Spacer()
 
            VStack(spacing: 20) {
                trackInfo
                progress
                controls
            }
            .padding(.horizontal, 24)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(viewModel.playingMusic?.collectionName ?? "")
                    .font(.headline)
                    .foregroundStyle(.element07)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.moreInfo()
                } label: {
                    Image(.ellipsis)
                        .foregroundStyle(.element07)
                        .frame(width: 36, height: 36)
                }
            }
        }
        .toolbarBackground(.black, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        
        .task {
            viewModel.setupPlayer()
        }
    }
 
    private var trackInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(viewModel.playingMusic?.trackName ?? "")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(.text03)
                .lineLimit(1)
            
            HStack(alignment: .center) {
                Text(viewModel.playingMusic?.singer ?? "")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.text70)
                    .lineLimit(1)
                
                Spacer()
                
                Button {
                    viewModel.toggleRepeat()
                } label: {
                    Image(.playOnRepeat)
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .foregroundStyle(viewModel.isRepeating ? .element03 : .element07)
                }
            }
        }
 
    }
    
    private var progress: some View {
        VStack(spacing: 6) {
            Slider(value: $viewModel.currentTime,
                   in: 0...(viewModel.playingMusic?.duration ?? 30),
                   onEditingChanged: { editing in
                       if !editing { viewModel.seek(to: viewModel.currentTime) }
                   })
            .tint(.element07)
 
            HStack {
                Text(viewModel.currentTime.asPlaybackTime)
                Spacer()
                Text("-" + (viewModel.remainingTime?.asPlaybackTime ?? ""))
                    .opacity(viewModel.remainingTime == nil ? 0 : 1)
            }
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(.text60)
        }
    }
    
    private var controls: some View {
        HStack(spacing: 28) {
            Button {
                viewModel.previous()
            } label: {
                Image(.backward)
                    .scaledToFill()
                    .frame(width: 36, height: 36)
                    .foregroundStyle(.element07)
            }
            .opacity(viewModel.canGoPrevious ? 1 : 0.3)
            .disabled(!viewModel.canGoPrevious)

            Button {
                viewModel.togglePlay()
            } label: {
                Image(viewModel.isPlaying ? .pause : .play)
                    .font(.largeTitle)
                    .foregroundStyle(.element07)
                    .frame(width: 72, height: 72)
                    .background(.clear, in: .circle)
                    .glassEffect(.regular, in: .circle)
            }
 
            Button {
                viewModel.next()
            } label: {
                Image(.forward)
                    .scaledToFill()
                    .frame(width: 36, height: 36)
                    .foregroundStyle(.element07)
            }
            .opacity(viewModel.canGoNext ? 1 : 0.3)
            .disabled(!viewModel.canGoNext)
        }
    }
}
