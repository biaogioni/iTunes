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
    
    init(musicInfo: TrackItemModel, router: Router) {
        _viewModel = State(wrappedValue: PlayerViewModel(musicInfo: musicInfo, router: router))
    }
 
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            AsyncImage(url: viewModel.musicInfo.musicCover) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    Rectangle().fill(.quaternary)
                }
            }
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
                Text(viewModel.musicInfo.collectionName ?? "")
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
    }
 
    private var trackInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(viewModel.musicInfo.trackName)
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(.text03)
                .lineLimit(1)
            
            HStack(alignment: .center) {
                Text(viewModel.musicInfo.singer)
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
                        .foregroundStyle(/*viewModel.isRepeating ? .blue :*/ .element07)
                }
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
            .tint(.element07)
 
            HStack {
                Text(viewModel.currentTime.asPlaybackTime)
                Spacer()
//                Text("-" + viewModel.remainingTime.asPlaybackTime)
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
        }
    }
}
